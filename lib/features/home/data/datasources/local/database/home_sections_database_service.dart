import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached home feed.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// home-sections box and return whatever Hive holds, as-is. No error handling
/// and no serialization live here — the repository JSON-encodes the raw server
/// `data` payload before [saveHomeSections] and decodes the raw string after
/// [getHomeSections], and maps failures into a `Failure`.
class HomeSectionsDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.homeSections);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.homeSectionsPayload], or `null` when nothing has been cached yet.
  String? getHomeSections() =>
      _box.get(HiveKeys.homeSectionsPayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveHomeSections(String data) =>
      _box.put(HiveKeys.homeSectionsPayload, data);
}
