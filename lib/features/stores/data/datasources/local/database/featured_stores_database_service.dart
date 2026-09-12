import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached featured stores ("Best brands").
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// featured-stores box and return whatever Hive holds, as-is. No error handling
/// and no serialization live here — the repository JSON-encodes the raw server
/// `data` payload before [saveFeaturedStores] and decodes the raw string after
/// [getFeaturedStores], and maps failures into a `Failure`.
class FeaturedStoresDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.featuredStores);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.featuredStoresPayload], or `null` when nothing has been cached
  /// yet.
  String? getFeaturedStores() =>
      _box.get(HiveKeys.featuredStoresPayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveFeaturedStores(String data) =>
      _box.put(HiveKeys.featuredStoresPayload, data);

  /// Removes the cached payload entirely.
  Future<void> clearFeaturedStores() =>
      _box.delete(HiveKeys.featuredStoresPayload);
}
