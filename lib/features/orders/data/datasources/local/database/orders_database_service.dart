import 'package:hive/hive.dart';
import 'package:nowdelivery_user_app/core/database/hive_boxes.dart';
import 'package:nowdelivery_user_app/core/database/hive_keys.dart';
import 'package:nowdelivery_user_app/core/database/hive_manager.dart';

/// Raw local database access for the cached my-orders payload.
///
/// The Hive counterpart of [OrdersApiService]: its only role is to read/write
/// the my-orders box and return whatever Hive holds, as-is. The value stored is
/// the raw API payload serialized as a JSON string (see [HiveKeys.myOrders]);
/// all encoding, decoding and error handling live in the repository.
class OrdersDatabaseService {
  Box<dynamic> get _box => HiveManager.box(HiveBoxes.myOrders);

  /// Returns the raw stored value under [HiveKeys.myOrders] (a JSON `String`
  /// when present), or `null` when nothing has been cached yet.
  dynamic getCachedOrders() => _box.get(HiveKeys.myOrders);

  /// Overwrites the cached orders with [ordersJson] (a JSON string).
  Future<void> saveOrders(String ordersJson) =>
      _box.put(HiveKeys.myOrders, ordersJson);

  /// Removes the cached orders entirely (e.g. on logout).
  Future<void> clearAll() => _box.delete(HiveKeys.myOrders);
}
