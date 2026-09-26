import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached app categories list.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// app-categories box and return whatever Hive holds, as-is. No error handling
/// and no serialization live here — the repository JSON-encodes the raw server
/// `data` payload before [saveAppCategories] and decodes the raw string after
/// [getAppCategories], and maps failures into a `Failure`.
class AppCategoriesDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.appCategories);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.appCategoriesPayload], or `null` when nothing has been cached
  /// yet.
  String? getAppCategories() =>
      _box.get(HiveKeys.appCategoriesPayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveAppCategories(String data) =>
      _box.put(HiveKeys.appCategoriesPayload, data);
}
