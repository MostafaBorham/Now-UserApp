/// Keys used with `SharedPrefManager` for local caching.
///
/// Every cached value must have its key declared here so all cache keys
/// live in one place and collisions are impossible.
abstract class CacheKeys {
  /// JSON-encoded map: `{'token': String, 'isGuest': bool}`.
  static const String token = 'token';

  /// Keys inside the [token] map.
  static const String tokenValue = 'token';
  static const String isGuest = 'isGuest';
}
