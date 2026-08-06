import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the orders feature's cached my-orders list.
///
/// The Hive counterpart of an API service: its only role is to read/write the
/// my-orders box and return whatever Hive holds, as-is. No error handling and
/// no formatting live here — the repository owns the JSON encode/decode, the
/// pagination accumulation and the mapping of failures into a `Failure`.
class MyOrdersDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.myOrders);

  /// Returns the JSON-encoded orders payload stored under
  /// [HiveKeys.myOrdersPayload], or `null` when nothing has been cached yet.
  String? getOrdersPayload() =>
      _box.get(HiveKeys.myOrdersPayload) as String?;

  /// Overwrites the stored orders payload with [payload] (a JSON string of the
  /// accumulated orders list plus its pagination counters).
  Future<void> saveOrdersPayload(String payload) =>
      _box.put(HiveKeys.myOrdersPayload, payload);

  /// Reads the freshness flag. Absent (never written) reads as `false` — an
  /// empty cache is not considered in sync with the server.
  bool getIsUpdated() =>
      _box.get(HiveKeys.myOrdersIsUpdated) as bool? ?? false;

  /// Sets the freshness flag: `true` right after a successful cache write,
  /// `false` when a write failed and the cache no longer matches the server.
  Future<void> setIsUpdated(bool value) =>
      _box.put(HiveKeys.myOrdersIsUpdated, value);

  /// Wipes the whole box — both the payload and the flag. Used on sign-out so a
  /// previous account's orders never leak into the next session.
  Future<void> clear() => _box.clear();
}
