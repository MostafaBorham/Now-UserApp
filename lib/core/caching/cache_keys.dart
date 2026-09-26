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

  /// The device's current location, reverse-geocoded into an address and stored
  /// as JSON. Written by the splash once a location is obtained and read as the
  /// default delivery address in the home header. This value must never be
  /// null before the app is entered (see `CurrentLocationViewModel`).
  static const String currentLocation = 'current_location';

  /// The first-order welcome voucher code (e.g. `WELCOME10`). Refreshed from the
  /// server on every splash and read back offline so the empty cart and guest
  /// settings can still show a promo code. Stored as the raw code string.
  static const String welcomeVoucherCode = 'welcome_voucher_code';

  /// The id of the delivered order the "rate your order" prompt was last shown
  /// for, so it is offered once per order. Not purged on logout: an order id
  /// belongs to one customer, so another account's orders never match it.
  static const String ratePromptedOrderId = 'rate_prompted_order_id';
}
