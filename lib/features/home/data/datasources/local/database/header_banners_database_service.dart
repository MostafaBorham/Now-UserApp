import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached home header banners.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// header-banners box and return whatever Hive holds, as-is. No error handling
/// and no serialization live here — the repository JSON-encodes the raw server
/// `data` payload before [saveHeaderBanners] and decodes the raw string after
/// [getHeaderBanners], and maps failures into a `Failure`.
class HeaderBannersDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.headerBanners);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.headerBannersPayload], or `null` when nothing has been cached
  /// yet.
  String? getHeaderBanners() =>
      _box.get(HiveKeys.headerBannersPayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveHeaderBanners(String data) =>
      _box.put(HiveKeys.headerBannersPayload, data);

  /// Removes the cached payload entirely.
  Future<void> clearHeaderBanners() =>
      _box.delete(HiveKeys.headerBannersPayload);
}
