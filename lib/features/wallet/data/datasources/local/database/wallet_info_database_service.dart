import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached wallet payload.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// wallet-info box and return whatever Hive holds, as-is. No error handling and
/// no serialization live here — the repository JSON-encodes the raw server
/// `data` payload before [saveWalletInfo] and decodes the raw string after
/// [getWalletInfo], and maps failures into a `Failure`.
class WalletInfoDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.walletInfo);

  /// Returns the raw JSON-encoded payload stored under
  /// [HiveKeys.walletInfoPayload], or `null` when nothing has been cached yet.
  String? getWalletInfo() => _box.get(HiveKeys.walletInfoPayload) as String?;

  /// Overwrites the cached payload with the JSON-encoded [data].
  Future<void> saveWalletInfo(String data) =>
      _box.put(HiveKeys.walletInfoPayload, data);
}
