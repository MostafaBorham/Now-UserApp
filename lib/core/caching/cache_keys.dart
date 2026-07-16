/// Keys used with `SharedPrefManager` for local caching.
///
/// Every cached value must have its key declared here so all cache keys
/// live in one place and collisions are impossible.
abstract class CacheKeys {
  static const String guestToken = 'guest_token';
}
