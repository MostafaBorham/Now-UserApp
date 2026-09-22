import 'dart:async';

import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/dio/dio_constants.dart';
import 'package:nowdelivery_user_app/core/dio/interceptors/dio_logger.dart';

/// How a refresh attempt ended.
///
/// The distinction between the last two is the whole point: only one of them
/// means the user's session is over.
enum _RefreshOutcome {
  /// A new access + refresh pair is cached. Replay the original request.
  refreshed,

  /// The endpoint refused the refresh token itself (`401`/`403`), or answered
  /// cleanly without issuing a pair. The session cannot be recovered.
  rejected,

  /// The attempt never produced an answer — rate limited, server error,
  /// timeout, connection dropped. The refresh token may well still be valid, so
  /// the session must survive and the caller simply sees its original `401`.
  unavailable,
}

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
/// 3. On any refresh failure the session is unrecoverable, so it is ended: the
///    dead tokens are cleared and [onSessionExpired] runs, then the **original**
///    `401` is surfaced on the request that triggered it.
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
///
/// One distinction matters more than it looks: a refresh that *fails* is not the
/// same as a refresh token that is *rejected*. See [_RefreshOutcome].
class TokenRefreshInterceptor extends Interceptor {
  /// [refreshDio] exists so a test can decide what the refresh endpoint answers
  /// — the difference between a `401` and a `429` there decides whether the
  /// user keeps their session, which is not something to leave unpinned.
  /// Production always takes the default.
  TokenRefreshInterceptor(this._dio, {Dio? refreshDio})
      : _refreshDio = refreshDio ?? _buildRefreshDio();

  /// Runs once when a refresh fails and the user session is gone for good, so
  /// the app can drop the previous user's data and return to onboarding.
  ///
  /// ponytail: a single static hook, because an interceptor lives outside the
  /// widget tree and has no Riverpod `Ref`. It is assigned once at the app root
  /// (`NowUserApp.build`) and is `null` in tests and before the first frame —
  /// the tokens are cleared either way, so a missing hook only costs the
  /// navigation. Swap it for a globally held `ProviderContainer` if a second
  /// listener ever needs the same signal.
  static Future<void> Function()? onSessionExpired;

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
  final Dio _refreshDio;

  static Dio _buildRefreshDio() => Dio(
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
  /// runs. `null` when idle.
  Future<_RefreshOutcome>? _refreshGate;

  /// The twin of [_refreshGate], for the expiry itself. Every `401` in a burst
  /// resumes from the *same* failed refresh, so each one would otherwise run
  /// the purge and the navigation again.
  Future<void>? _expiryGate;

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

    // A multipart body is a one-shot stream: by the time the `401` comes back it
    // has already been consumed, so replaying it would upload an empty file and
    // report success. Surface the `401` instead and let the caller re-submit —
    // a visible error beats a save that silently drops the user's picture.
    if (request.data is FormData) {
      return handler.next(err);
    }

    // A guest has no session to refresh and none to expire, so a `401` here is
    // the endpoint's own answer (it wanted a logged-in user), not an expiry.
    // Without this the refresh below would "fail" for every guest — there is no
    // refresh token to send — and purge someone who was never signed in.
    if (!_tokenCache.hasAccessToken) {
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
    final _RefreshOutcome outcome = await (_refreshGate ??= _refreshTokens());

    switch (outcome) {
      case _RefreshOutcome.refreshed:
        return _replay(request, handler, err);

      // The refresh token itself was refused, so the session really is over.
      // Awaiting the purge first is deliberate: it invalidates the calling view
      // model, so its own `!mounted` guard swallows the error instead of
      // flashing it on a screen that is already being torn down.
      case _RefreshOutcome.rejected:
        await _expireSession();
        return handler.next(err);

      // The refresh never got an answer — rate limited, server error, timeout,
      // connection dropped. None of that says the token is dead, so the session
      // is left alone and the original `401` is surfaced for the caller to
      // retry. Signing the user out here used to throw people off shared
      // networks at random: the refresh endpoint is rate limited per IP, so on
      // carrier-grade NAT one customer's refresh could 429 because of another's.
      case _RefreshOutcome.unavailable:
        return handler.next(err);
    }
  }

  /// Clears the dead tokens and runs [onSessionExpired] exactly once per expiry.
  ///
  /// Never throws — a forced logout must not replace the `401` the caller is
  /// still waiting for. The tokens are cleared here rather than in the hook so
  /// the session ends even when nothing is wired up (tests, before the first
  /// frame). The gate is released at the end so a later session can expire in
  /// its turn.
  Future<void> _expireSession() {
    return _expiryGate ??= Future<void>(() async {
      try {
        await _tokenCache.clearUserTokens();
        await onSessionExpired?.call();
      } catch (_) {
        // Best-effort: the `401` below is what the caller gets either way.
      } finally {
        _expiryGate = null;
      }
    });
  }

  /// Performs the one refresh request and persists the new tokens. Always
  /// clears [_refreshGate] when done so a later expiry can refresh again.
  /// Never throws.
  Future<_RefreshOutcome> _refreshTokens() async {
    try {
      final String refreshToken = _tokenCache.getRefreshToken() ?? '';
      // Nothing to refresh with: there is no session left to save.
      if (refreshToken.isEmpty) return _RefreshOutcome.rejected;

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

      // A clean answer that carries no usable pair is the server declining to
      // reissue, not a transport problem — treat it as a refusal.
      if (newAccess.isEmpty || newRefresh.isEmpty) {
        return _RefreshOutcome.rejected;
      }

      await _tokenCache.saveUserTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return _RefreshOutcome.refreshed;
    } on DioException catch (error) {
      // Only the endpoint saying "no" means the refresh token is dead —
      // `auth:sanctum` answers 401 for an unknown or revoked token, and the
      // action answers 403 when the token is not a refresh token. A 429 (the
      // endpoint is rate limited per IP), a 5xx, a timeout or a dropped
      // connection all leave the token perfectly valid.
      final int? statusCode = error.response?.statusCode;
      return statusCode == 401 || statusCode == 403
          ? _RefreshOutcome.rejected
          : _RefreshOutcome.unavailable;
    } catch (_) {
      // Could not even complete the attempt (e.g. the token cache refused the
      // write). Says nothing about the token, so keep the session.
      return _RefreshOutcome.unavailable;
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
