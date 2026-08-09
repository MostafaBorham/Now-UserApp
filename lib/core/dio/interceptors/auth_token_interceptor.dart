import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';

/// Authenticates every outgoing request from the cached session, with no
/// per-request configuration needed anywhere in the app.
///
/// On each request the cached tokens are read straight from the store (never
/// through a feature data source), so the header always reflects the latest
/// session:
///
/// * an access token is cached → `Authorization: Bearer <accessToken>`
///   (the logged-in user); it always wins over a leftover guest token.
/// * otherwise a guest token is cached → `X-Guest-Token: <guestToken>`.
///
/// The header flips from the guest token to the bearer automatically once OTP
/// verification saves the access token. When neither token is cached yet (e.g.
/// the guest-token request itself), no auth header is attached.
class AuthTokenInterceptor extends Interceptor {
  static const String _guestHeaderKey = 'X-Guest-Token';
  static const String _authHeaderKey = 'Authorization';

  final TokenCacheService _tokenCache = TokenCacheService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final String accessToken = _tokenCache.getAccessToken() ?? '';
    if (accessToken.isNotEmpty) {
      options.headers[_authHeaderKey] = 'Bearer $accessToken';
    } else {
      final String guestToken = _tokenCache.getGuestToken() ?? '';
      if (guestToken.isNotEmpty) {
        options.headers[_guestHeaderKey] = guestToken;
      }
    }
    handler.next(options);
  }
}
