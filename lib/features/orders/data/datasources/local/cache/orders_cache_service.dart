import 'package:nowdelivery_user_app/core/caching/cache_exceptions.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/caching/shared_pref_manager.dart';

/// Local caching operations of the orders feature — the freshness flag of the
/// my-orders cache.
///
/// The payload itself lives in Hive (`OrdersDatabaseService`); only the small
/// `bool` saying whether that payload still matches the server belongs here, in
/// key/value storage. Raw reads/writes against [SharedPrefManager] only, so the
/// repository never touches the cache mechanism directly; failures surface as
/// [CacheException] for the repository to handle.
class OrdersCacheService {
  /// `true` when the cached my-orders payload is known to match the server.
  ///
  /// Defaults to `false` when nothing has been stored yet — an unknown cache is
  /// a stale cache, so the repository fetches. A genuine read error surfaces as
  /// a [CacheException].
  bool isMyOrdersUpdated() {
    try {
      return SharedPrefManager.getBool(CacheKeys.isMyOrdersUpdated) ?? false;
    } catch (_) {
      throw const CacheException(CacheException.ordersCacheStateFailedMessage);
    }
  }

  /// Persists [isUpdated] under [CacheKeys.isMyOrdersUpdated]. A write failure
  /// surfaces as a [CacheException]: the caller must never assume the flag was
  /// stored, since a wrongly-`true` flag would keep serving a stale cache.
  Future<void> saveMyOrdersUpdated(bool isUpdated) async {
    final bool saved = await SharedPrefManager.setBool(
      CacheKeys.isMyOrdersUpdated,
      isUpdated,
    );
    if (!saved) {
      throw const CacheException(CacheException.ordersCacheStateFailedMessage);
    }
  }

  /// Removes the flag entirely (e.g. on logout), which reads back as `false`.
  Future<void> clearMyOrdersUpdated() async {
    final bool removed = await SharedPrefManager.remove(
      CacheKeys.isMyOrdersUpdated,
    );
    if (!removed) {
      throw const CacheException(CacheException.ordersCacheStateFailedMessage);
    }
  }
}
