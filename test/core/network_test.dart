import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_services/core/network/api_call.dart';
import 'package:urban_services/core/network/api_failure.dart';
import 'package:urban_services/core/network/api_logger_interceptor.dart';
import 'package:urban_services/core/network/api_result.dart';
import 'package:urban_services/core/network/auth_interceptor.dart';

/// Answers every request with [handler] instead of hitting the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

Dio _dio(_FakeAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://api.test/'))..httpClientAdapter = adapter;

void main() {
  group('safeApiCall', () {
    test('status: true is a success and is parsed', () async {
      final dio = _dio(
        _FakeAdapter((_) => _json({'status': true, 'message': 'ok'}, 200)),
      );
      final result = await safeApiCall(
        () => dio.get('x'),
        (json) => json['message'] as String,
      );
      expect(result, isA<ApiSuccess<String>>());
      expect((result as ApiSuccess<String>).data, 'ok');
    });

    test(
      '200 with status: false becomes an ApiError with the server message',
      () async {
        final dio = _dio(
          _FakeAdapter(
            (_) => _json({'status': false, 'message': 'No address'}, 200),
          ),
        );
        final result = await safeApiCall(() => dio.get('x'), (json) => json);
        expect(result, isA<ApiError<Map<String, dynamic>>>());
        expect((result as ApiError).failure.message, 'No address');
      },
    );

    test(
      '422 maps to validation with field errors and a readable message',
      () async {
        final dio = _dio(
          _FakeAdapter(
            (_) => _json({
              'status': false,
              'message': {
                'email': ['The email has already been taken.'],
              },
            }, 422),
          ),
        );
        final result = await safeApiCall(() => dio.post('x'), (json) => json);
        final failure = (result as ApiError).failure;
        expect(failure.type, ApiFailureType.validation);
        expect(failure.statusCode, 422);
        expect(failure.message, 'The email has already been taken.');
        expect(failure.fieldErrors?['email'], [
          'The email has already been taken.',
        ]);
      },
    );

    test(
      'a parser exception becomes an ApiError instead of throwing',
      () async {
        final dio = _dio(_FakeAdapter((_) => _json({'status': true}, 200)));
        final result = await safeApiCall(
          () => dio.get('x'),
          (json) => json['missing'] as String,
        );
        expect((result as ApiError).failure.type, ApiFailureType.unknown);
      },
    );
  });

  group('AuthInterceptor', () {
    late _FakeAdapter adapter;
    late Dio dio;
    late int expiredCalls;

    setUp(() {
      expiredCalls = 0;
      adapter = _FakeAdapter(
        (_) => _json({'message': 'Unauthenticated.'}, 401),
      );
      dio = _dio(adapter);
      dio.interceptors.add(
        AuthInterceptor(
          dio,
          readToken: () async => 'token-123',
          refreshToken: () async => null,
          onAuthExpired: () async => expiredCalls++,
        ),
      );
    });

    test('attaches the bearer token', () async {
      await safeApiCall(() => dio.get('x'), (json) => json);
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer token-123',
      );
    });

    test('concurrent 401s end the session exactly once', () async {
      final results = await Future.wait([
        safeApiCall(() => dio.get('a'), (json) => json),
        safeApiCall(() => dio.get('b'), (json) => json),
      ]);
      expect(expiredCalls, 1);
      for (final r in results) {
        expect((r as ApiError).failure.type, ApiFailureType.unauthorized);
      }
    });

    test(
      '401 on a skipAuth request (login) does not end the session',
      () async {
        final result = await safeApiCall(
          () => dio.post(
            'login',
            options: Options(extra: {AuthInterceptor.skipAuthKey: true}),
          ),
          (json) => json,
        );
        expect(expiredCalls, 0);
        expect((result as ApiError).failure.statusCode, 401);
      },
    );
  });

  group('ApiLoggerInterceptor', () {
    test(
      'logs request, response with duration, and redacts API keys',
      () async {
        final lines = <String>[];
        final original = debugPrint;
        debugPrint = (message, {wrapWidth}) => lines.add(message ?? '');
        addTearDown(() => debugPrint = original);

        final dio = _dio(
          _FakeAdapter((_) => _json({'status': true, 'data': []}, 200)),
        )..interceptors.add(ApiLoggerInterceptor());

        await dio.get('items', queryParameters: {'key': 'secret', 'page': 1});
        final log = lines.join('\n');

        expect(log, contains('→ ['));
        expect(log, contains('GET https://api.test/items?key=***&page=1'));
        expect(log, contains('cURL: curl -X GET'));
        expect(log, contains('← ['));
        expect(log, matches(RegExp(r'200 GET .* \(\d+ ms\)')));
        expect(log, isNot(contains('secret')));
      },
    );
  });
}
