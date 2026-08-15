/// Keys used with `SharedPrefManager` for local caching.
///
/// Every cached value must have its key declared here so all cache keys
/// live in one place and collisions are impossible.
abstract class CacheKeys {
  /// The guest session token. Sent as the `X-Guest-Token` header (never as a
  /// bearer). Issued only when the user continues as a guest from onboarding.
  static const String guestToken = 'guest_token';

  /// The authenticated user's access token. Sent as `Authorization: Bearer`
  /// on every request. Issued by OTP verification and refreshed via the token
  /// refresh endpoint.
  static const String accessToken = 'access_token';

  /// The authenticated user's refresh token. Used only to obtain a new
  /// [accessToken] when the server answers `401`. Issued alongside the access
  /// token by OTP verification and by the refresh endpoint itself.
  static const String refreshToken = 'refresh_token';

  static const String isGuest = 'isGuest';
  static const String token = 'token';
  static const String tokenValue = 'token';
}
