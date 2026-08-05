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

  /// `bool` — `true` while the my-orders payload cached in Hive is known to
  /// match the server, so the orders can be served from the cache without a
  /// request. Reset to `false` whenever the orders may have changed.
  static const String isMyOrdersUpdated = 'isMyOrdersUpdated';
}
