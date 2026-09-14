import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached user-profile payload.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// user-profile box and return whatever Hive holds, as-is. No error handling
/// and no serialization live here — the repository JSON-encodes the raw server
/// `data` payload before [saveProfile] and decodes the raw string after
/// [getProfile], and maps failures into a `Failure`.
class ProfileDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.userProfile);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.userProfilePayload], or `null` when nothing has been cached yet.
  String? getProfile() => _box.get(HiveKeys.userProfilePayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveProfile(String data) =>
      _box.put(HiveKeys.userProfilePayload, data);

  // Clearing on logout is not done here: `CachePurger` wipes this box along with
  // every other user-scoped one, from the single place the session drops to
  // guest, so no feature has to remember to do it.
}
