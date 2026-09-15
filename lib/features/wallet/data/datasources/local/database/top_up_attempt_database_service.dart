import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the unresolved top-up attempt.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// top-up-attempt box and return whatever Hive holds, as-is. No error handling
/// and no serialization live here — the repository JSON-encodes the attempt
/// before [saveTopUpAttempt] and decodes the raw string after
/// [getTopUpAttempt], and maps failures into a `Failure`.
class TopUpAttemptDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.walletTopUpAttempt);

  /// Returns the raw JSON-encoded attempt stored under
  /// [HiveKeys.walletTopUpAttemptPayload], or `null` when no attempt is
  /// outstanding.
  String? getTopUpAttempt() =>
      _box.get(HiveKeys.walletTopUpAttemptPayload) as String?;

  /// Overwrites the stored attempt with the JSON-encoded [data].
  Future<void> saveTopUpAttempt(String data) =>
      _box.put(HiveKeys.walletTopUpAttemptPayload, data);

  /// Removes the stored attempt entirely.
  Future<void> clearTopUpAttempt() =>
      _box.delete(HiveKeys.walletTopUpAttemptPayload);
}
