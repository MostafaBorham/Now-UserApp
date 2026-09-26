import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached application-information payload.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// app-info box and return whatever Hive holds, as-is. No error handling and no
/// serialization live here — the repository JSON-encodes the model before
/// [saveAppInfo] and decodes the raw string after [getAppInfo], and maps
/// failures into a `Failure`.
class AppInfoDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.appInfo);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.appInfoPayload], or `null` when nothing has been cached yet.
  String? getAppInfo() => _box.get(HiveKeys.appInfoPayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveAppInfo(String data) =>
      _box.put(HiveKeys.appInfoPayload, data);
}
