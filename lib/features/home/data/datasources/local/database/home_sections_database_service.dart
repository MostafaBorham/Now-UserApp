import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached home feed.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// home-sections box and return whatever Hive holds, as-is. No error handling
/// and no serialization live here — the repository stores the raw response
/// body with [saveHomeSections] and decodes the string after
/// [getHomeSections], and maps failures into a `Failure`. Installs from before
/// that hold the bare `data` object instead; the decoder reads both.
class HomeSectionsDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.homeSections);

  /// Returns the raw JSON payload stored under
  /// [HiveKeys.homeSectionsPayload], or `null` when nothing has been cached yet.
  String? getHomeSections() =>
      _box.get(HiveKeys.homeSectionsPayload) as String?;

  /// Overwrites the cached payload with the raw JSON [data].
  Future<void> saveHomeSections(String data) =>
      _box.put(HiveKeys.homeSectionsPayload, data);
}
