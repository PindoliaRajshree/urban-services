import 'package:dio/dio.dart';

typedef TokenReader = Future<String?> Function();
typedef TokenRefresher = Future<String?> Function();
typedef OnAuthExpired = Future<void> Function();

/// Attaches the bearer token to every request and handles 401s.
///
/// Adapted from orbit_core's AuthInterceptor, with these fixes:
/// - refresh / replay errors are caught, so the handler always completes
///   (the original could leave a request hanging forever);
/// - `_isRefreshing` is reset in `finally`, so a throwing refresh can't
///   wedge every later 401 into the queue;
/// - [onAuthExpired] runs once per expiry, not once per failed request;
/// - requests marked with `extra[skipAuthKey] = true` (login, register,
///   forgot-password) never trigger the expiry flow — a 401 there just
///   means wrong credentials.
///
/// This backend has no refresh endpoint, so the app passes a refresher that
/// returns null and every 401 ends in [onAuthExpired] (clear session, go to
/// Welcome).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._dio, {
    required this.readToken,
    required this.refreshToken,
    required this.onAuthExpired,
  });

  static const String skipAuthKey = 'skipAuth';
  static const String _retriedKey = 'retried';

  final Dio _dio;
  final TokenReader readToken;
  final TokenRefresher refreshToken;
  final OnAuthExpired onAuthExpired;

  Future<String?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    if (!isUnauthorized ||
        options.extra[_retriedKey] == true ||
        options.extra[skipAuthKey] == true) {
      handler.next(err);
      return;
    }

    // Concurrent 401s share a single refresh attempt.
    final String? newToken;
    try {
      newToken = await (_refreshing ??= _refreshOnce());
    } catch (_) {
      handler.next(err);
      return;
    }

    if (newToken == null) {
      handler.next(err);
      return;
    }

    try {
      options.headers['Authorization'] = 'Bearer $newToken';
      options.extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<String?> _refreshOnce() async {
    try {
      final token = await refreshToken();
      if (token == null) await onAuthExpired();
      return token;
    } catch (_) {
      await onAuthExpired();
      return null;
    } finally {
      // Let the next expiry (e.g. after re-login) start a fresh attempt.
      Future<void>.delayed(const Duration(seconds: 1), () => _refreshing = null);
    }
  }
}
