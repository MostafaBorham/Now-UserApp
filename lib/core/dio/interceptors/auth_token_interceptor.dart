import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';

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
