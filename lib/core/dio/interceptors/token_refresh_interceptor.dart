import 'dart:async';

import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/dio/dio_constants.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/dio_logger.dart';

/// Transparently refreshes an expired access token on a `401` and replays the
/// request that failed, so no feature layer ever has to think about it.
///
/// The exact scenario, entirely inside the Dio error pipeline:
///
/// 1. A request comes back `401`. One — and only one — refresh is attempted:
///    a `POST` to [_refreshPath] carrying the **refresh token** as the bearer.
/// 2. On success the returned `access_token` / `refresh_token` pair is saved to
///    the cache, and the original request is replayed once with the new access
///    token; its result is resolved as if the `401` never happened.
/// 3. On any refresh failure we stop and surface the **original** `401` on the
///    request that triggered it — no retry, no session mutation.
///
/// Two guards keep this from misbehaving under load:
/// * [_retriedFlag] — a replayed request that `401`s again is not refreshed a
///   second time (no infinite loop).
/// * [_refreshGate] — concurrent `401`s share the single in-flight refresh
///   instead of each spending the (single-use) refresh token; a straggler that
///   failed with an already-rotated token is simply replayed with the current
///   one.
///
/// This is a plain (non-queued) [Interceptor]: replaying through the shared Dio
/// re-runs `onRequest`, so a [QueuedInterceptor] would deadlock waiting on its
/// own queue. Single-flight is handled explicitly with [_refreshGate] instead.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor(this._dio);

  /// The shared Dio used to replay the original request (so it re-runs every
  /// interceptor, including the auth-header attachment with the fresh token).
  final Dio _dio;

  final TokenCacheService _tokenCache = TokenCacheService();

  /// Path of the refresh endpoint. The refresh token is sent as the bearer.
  static const String _refreshPath = '/api/v1/auth/user/refresh';

  /// Marks a request that has already been replayed once, so a second `401`
  /// fails instead of looping forever.
  static const String _retriedFlag = 'token_refresh_retried';

  /// Bare Dio dedicated to the refresh call: no auth interceptor (it must carry
  /// the refresh token, not the access token) and no refresh interceptor (it
  /// must never recurse into itself). Keeps the logger for debug visibility.
  late final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: DioConstants.baseUrl,
      connectTimeout: DioConstants.timeout,
      receiveTimeout: DioConstants.timeout,
      sendTimeout: DioConstants.timeout,
      responseType: ResponseType.json,
      headers: DioConstants.defaultHeaders,
    ),
  )..interceptors.add(DioLogger.logger);

  /// The single in-flight refresh shared by every `401` that arrives while it
  /// runs. `null` when idle; completes `true` on a successful refresh.
  Future<bool>? _refreshGate;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;

    // Only a first-time `401` is our business. A replayed request that `401`s
    // again is passed straight through (the refresh call itself runs on a
    // separate Dio, so its `401` never reaches here).
    if (err.response?.statusCode != 401 ||
        request.extra[_retriedFlag] == true) {
      return handler.next(err);
    }

    // Another request already refreshed the token while this one was in flight:
    // the cached access token no longer matches the one we sent, so just replay
    // — don't spend the refresh token a second time.
    final String currentAccess = _tokenCache.getAccessToken() ?? '';
    final String? sentAuth = request.headers['Authorization'] as String?;
    if (currentAccess.isNotEmpty && sentAuth != 'Bearer $currentAccess') {
      return _replay(request, handler, err);
    }

    // One refresh attempt, shared across concurrent `401`s.
    final bool refreshed = await (_refreshGate ??= _refreshTokens());

    // Refresh failed → stop and surface the original `401` on this request.
    if (!refreshed) {
      return handler.next(err);
    }

    return _replay(request, handler, err);
  }

  /// Performs the one refresh request and persists the new tokens. Always
  /// clears [_refreshGate] when done so a later expiry can refresh again.
  /// Returns whether the refresh succeeded; never throws.
  Future<bool> _refreshTokens() async {
    try {
      final String refreshToken = _tokenCache.getRefreshToken() ?? '';
      if (refreshToken.isEmpty) return false;

      final Response response = await _refreshDio.post(
        _refreshPath,
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $refreshToken'},
        ),
      );

      final dynamic body = response.data;
      final Map<String, dynamic>? data = body is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>?
          : null;

      final String newAccess = data?['access_token'] as String? ?? '';
      final String newRefresh = data?['refresh_token'] as String? ?? '';
      if (newAccess.isEmpty || newRefresh.isEmpty) return false;

      await _tokenCache.saveUserTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshGate = null;
    }
  }

  /// Replays [request] once through the shared Dio with the current access
  /// token, resolving the retried response on success and surfacing the
  /// [originalError] otherwise.
  Future<void> _replay(
    RequestOptions request,
    ErrorInterceptorHandler handler,
    DioException originalError,
  ) async {
    request.extra[_retriedFlag] = true;
    // AuthTokenInterceptor re-attaches the header on replay; set it here too so
    // the token is correct even without that interceptor in the chain.
    request.headers['Authorization'] =
        'Bearer ${_tokenCache.getAccessToken() ?? ''}';

    try {
      final Response response = await _dio.fetch(request);
      // Success → hand the response back to the waiting service as normal.
      handler.resolve(response);
    } on DioException catch (error) {
      // Error → pass the replayed request's own error straight through
      // (do not swallow or stop it).
      handler.next(error);
    } catch (_) {
      handler.next(originalError);
    }
  }
}
