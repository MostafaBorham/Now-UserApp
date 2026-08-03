/// Names of the Hive boxes used across the app.
///
/// Every box must have its name declared here so all box names live in one
/// place and collisions are impossible (the Hive counterpart of `CacheKeys`).
abstract class HiveBoxes {
  /// Box storing the user's recent search keywords.
  static const String recentSearches = 'recent_searches_box';

  /// Box storing the user's recent *address* search keywords. Kept apart from
  /// [recentSearches] so a picked area never shows up as a product keyword.
  static const String recentAddressSearches = 'recent_address_searches_box';
}
