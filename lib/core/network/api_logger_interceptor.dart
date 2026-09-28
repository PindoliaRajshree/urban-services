import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only console logger for every API call.
///
/// Each call prints three things, tagged with a short request id so
/// concurrent calls can be paired up:
///   → request: method, full URL, headers, query, body (+ a copy-paste curl)
///   ← response: status, duration, pretty JSON body
///   ✖ error: DioException type, status, duration, error body
///
/// Only add this in debug builds (see [AppDio.create]) — it prints tokens'
/// prefixes and full request/response payloads.
class ApiLoggerInterceptor extends Interceptor {
  ApiLoggerInterceptor({
    this.name = 'API',
    this.redactQueryKeys = const {'key'},
  });

  /// Tag shown in the console (`[API]`, `[GEOCODING]`, ...).
  final String name;

  /// Query parameter names whose values are masked in URLs (e.g. API keys).
  final Set<String> redactQueryKeys;

  static const _startKey = '_log_start';
  static const _idKey = '_log_id';
  static const _chunkSize = 800;
  static int _counter = 0;

  static const _encoder = JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = (++_counter).toRadixString(36).padLeft(3, '0');
    options.extra[_idKey] = id;
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer()
      ..writeln('┌── → [$id] ${options.method} ${_url(options.uri)}')
      ..writeln('│ Headers: ${_pretty(_safeHeaders(options.headers))}');
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln(
        '│ Query: ${_pretty(_redactMap(options.queryParameters))}',
      );
    }
    if (options.data != null) {
      buffer.writeln('│ Body: ${_body(options.data)}');
    }
    buffer
      ..writeln('│ cURL: ${_curl(options)}')
      ..write('└──────────────────────────────');
    _log(buffer.toString());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    _log(
      '┌── ← [${options.extra[_idKey]}] ${response.statusCode} '
      '${options.method} ${_url(options.uri)} (${_elapsed(options)})\n'
      '│ Response: ${_pretty(response.data)}\n'
      '└──────────────────────────────',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final buffer = StringBuffer()
      ..writeln(
        '┌── ✖ [${options.extra[_idKey]}] ${err.type.name} '
        '${err.response?.statusCode ?? '-'} ${options.method} '
        '${_url(options.uri)} (${_elapsed(options)})',
      );
    if (err.message != null) buffer.writeln('│ Message: ${err.message}');
    if (err.response?.data != null) {
      buffer.writeln('│ Error body: ${_pretty(err.response!.data)}');
    }
    if (err.response == null && err.error != null) {
      buffer.writeln('│ Cause: ${err.error}');
    }
    buffer.write('└──────────────────────────────');
    _log(buffer.toString(), isError: true);

    handler.next(err);
  }

  // ---------------------------------------------------------------------------

  String _elapsed(RequestOptions options) {
    final start = options.extra[_startKey];
    if (start is! int) return '? ms';
    return '${DateTime.now().millisecondsSinceEpoch - start} ms';
  }

  String _url(Uri uri) {
    var url = uri.toString();
    for (final key in redactQueryKeys) {
      url = url.replaceAllMapped(
        RegExp('([?&]${RegExp.escape(key)}=)[^&#]*'),
        (m) => '${m[1]}***',
      );
    }
    return url;
  }

  Map<String, dynamic> _redactMap(Map<String, dynamic> map) => {
    for (final e in map.entries)
      e.key: redactQueryKeys.contains(e.key) ? '***' : e.value,
  };

  /// Shortens the bearer token so the log shows *which* token was sent
  /// without dumping the whole secret.
  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) => {
    for (final e in headers.entries)
      e.key: e.key.toLowerCase() == 'authorization'
          ? _shortToken(e.value.toString())
          : e.value,
  };

  String _shortToken(String value) =>
      value.length > 24 ? '${value.substring(0, 20)}…' : value;

  String _body(Object data) {
    if (data is FormData) {
      final fields = {for (final f in data.fields) f.key: f.value};
      final files = {
        for (final f in data.files)
          f.key: '${f.value.filename ?? 'file'} (${_size(f.value.length)})',
      };
      return 'FormData ${_pretty({'fields': fields, 'files': files})}';
    }
    return _pretty(data);
  }

  String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _pretty(Object? data) {
    if (data == null) return 'null';
    try {
      final decoded = data is String ? jsonDecode(data) : data;
      return _encoder.convert(decoded).replaceAll('\n', '\n│ ');
    } catch (_) {
      return data.toString();
    }
  }

  String _curl(RequestOptions options) {
    final parts = <String>['curl -X ${options.method}'];
    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'content-length') return;
      parts.add("-H '$key: $value'");
    });
    final data = options.data;
    if (data is FormData) {
      for (final f in data.fields) {
        parts.add("-F '${f.key}=${f.value}'");
      }
      for (final f in data.files) {
        parts.add("-F '${f.key}=@${f.value.filename ?? 'file'}'");
      }
    } else if (data != null) {
      final body = data is String ? data : jsonEncode(data);
      parts.add("-d '${body.replaceAll("'", r"'\''")}'");
    }
    parts.add("'${_url(options.uri)}'");
    return parts.join(' ');
  }

  void _log(String message, {bool isError = false}) {
    // debugPrint shows in both the `flutter run` terminal and the IDE debug
    // console. Android's logcat cuts lines at ~1000 chars, so long lines
    // (big JSON strings, tokens, curl) are split into chunks.
    final tag = isError ? '[$name][ERROR]' : '[$name]';
    for (final line in message.split('\n')) {
      if (line.length <= _chunkSize) {
        debugPrint('$tag $line');
        continue;
      }
      for (var i = 0; i < line.length; i += _chunkSize) {
        final end = (i + _chunkSize < line.length)
            ? i + _chunkSize
            : line.length;
        debugPrint('$tag ${i == 0 ? '' : '│ … '}${line.substring(i, end)}');
      }
    }
  }
}
