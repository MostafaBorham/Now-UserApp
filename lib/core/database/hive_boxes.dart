/// Names of the Hive boxes used across the app.
///
/// Every box must have its name declared here so all box names live in one
/// place and collisions are impossible (the Hive counterpart of `CacheKeys`).
abstract class HiveBoxes {
  /// Box storing the user's recent search keywords.
  static const String recentSearches = 'recent_searches_box';
}
