import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached saved-cards payload.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// my-cards box and return whatever Hive holds, as-is. No error handling and no
/// serialization live here — the repository JSON-encodes the raw server `data`
/// payload before [saveMyCards] and decodes the raw string after [getMyCards],
/// and maps failures into a `Failure`.
class MyCardsDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.myCards);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.myCardsPayload], or `null` when nothing has been cached yet.
  String? getMyCards() => _box.get(HiveKeys.myCardsPayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveMyCards(String data) =>
      _box.put(HiveKeys.myCardsPayload, data);

  /// Removes the cached payload entirely.
  Future<void> clearMyCards() => _box.delete(HiveKeys.myCardsPayload);
}
