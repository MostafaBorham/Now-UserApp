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

  /// Key inside [HiveBoxes.myOrders] holding the cached orders as a JSON string
  /// (`{'orders': [...], 'pagination': {...}}` — the raw API payload).
  static const String myOrders = 'orders';
}
