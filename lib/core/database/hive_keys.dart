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

  /// Key inside [HiveBoxes.appInfo] holding the JSON-encoded `String` payload of
  /// the application-information response (`AppInfoModel.toJson`). Stored as a
  /// JSON string so it round-trips through `AppInfoModel.fromJson` with proper
  /// `String`-keyed maps.
  static const String appInfoPayload = 'app_info_payload';

  /// Key inside [HiveBoxes.appCategories] holding the JSON-encoded `String`
  /// payload of the first categories page — the raw server `data` object
  /// (`{'meta': {...}, 'categories': [...]}`). Stored as a JSON string so it
  /// round-trips back through the same parsing the server response uses, with
  /// proper `String`-keyed maps.
  static const String appCategoriesPayload = 'app_categories_payload';

  /// Key inside [HiveBoxes.userProfile] holding the JSON-encoded `String`
  /// payload of the profile response — the raw server `data` object (the
  /// `{'user': {...}}` envelope). Stored as a JSON string so it round-trips back
  /// through the same parsing the server response uses, with proper
  /// `String`-keyed maps.
  static const String userProfilePayload = 'user_profile_payload';

  /// Key inside [HiveBoxes.myCards] holding the JSON-encoded `String` payload of
  /// the saved-cards response — the raw server `data` object (`{'cards': [...]}`).
  /// Stored as a JSON string so it round-trips back through the same parsing the
  /// server response uses, with proper `String`-keyed maps.
  static const String myCardsPayload = 'my_cards_payload';

  /// Key inside [HiveBoxes.walletInfo] holding the JSON-encoded `String` payload
  /// of the wallet response — the raw server `data` object
  /// (`{'wallet': {...}, 'top_up': {...}}`). Stored as a JSON string so it
  /// round-trips back through the same parsing the server response uses, with
  /// proper `String`-keyed maps.
  static const String walletInfoPayload = 'wallet_info_payload';

  /// Key inside [HiveBoxes.homeSections] holding the JSON-encoded `String`
  /// payload of the home feed — the raw server `data` object
  /// (`{'sections': [...]}`). Stored as a JSON string so it round-trips back
  /// through the same parsing the server response uses, with proper
  /// `String`-keyed maps.
  static const String homeSectionsPayload = 'home_sections_payload';

  /// Key inside [HiveBoxes.headerBanners] holding the JSON-encoded `String`
  /// payload of the header banners — the raw server `data` object
  /// (`{'banners': [...]}`). Stored as a JSON string so it round-trips back
  /// through the same parsing the server response uses, with proper
  /// `String`-keyed maps.
  static const String headerBannersPayload = 'header_banners_payload';

  /// Key inside [HiveBoxes.featuredStores] holding the JSON-encoded `String`
  /// payload of the first featured-stores page — the raw server `data` object
  /// (`{'pagination': {...}, 'items': [...]}`). Stored as a JSON string so it
  /// round-trips back through the same parsing the server response uses, with
  /// proper `String`-keyed maps.
  static const String featuredStoresPayload = 'featured_stores_payload';
}
