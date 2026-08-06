/// Keys used to address values inside Hive boxes.
///
/// Declared centrally (like `CacheKeys` for SharedPreferences) so every value
/// stored in a box is addressed by a single, collision-free key.
abstract class HiveKeys {
  /// Key inside [HiveBoxes.recentSearches] holding the `List<String>` of
  /// recent search keywords (most-recent first).
  static const String recentSearchKeywords = 'keywords';

  /// Key inside [HiveBoxes.recentAddressSearches] holding the `List<String>` of
  /// recent address search keywords (most-recent first).
  static const String recentAddressSearchKeywords = 'address_keywords';

  /// Key inside [HiveBoxes.myOrders] holding the JSON-encoded `String` payload
  /// of the accumulated orders list plus its pagination counters
  /// (`{'orders': [...], 'pagination': {...}}`). Stored as a JSON string so it
  /// round-trips through `OrderModel.fromJson` with proper `String`-keyed maps.
  static const String myOrdersPayload = 'orders_payload';

  /// Key inside [HiveBoxes.myOrders] holding the `bool` freshness flag: `true`
  /// when the cached orders were last written straight from a successful server
  /// fetch, `false` when a cache write failed and the local copy no longer
  /// matches the server.
  static const String myOrdersIsUpdated = 'orders_is_updated';
}
