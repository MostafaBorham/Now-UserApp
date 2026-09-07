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

  /// Box storing the signed-in user's cached my-orders list (the accumulated
  /// paginated payload) together with its freshness flag, so the orders screen
  /// can render from local storage when the server is unreachable.
  static const String myOrders = 'my_orders_box';

  /// Box storing the cached application-information payload (the `content`
  /// text blocks and FAQs from `GET /api/v1/application-information`), so the
  /// privacy / FAQ screens can render from local storage when the server is
  /// unreachable.
  static const String appInfo = 'app_info_box';

  /// Box storing the cached first page of the app categories list (from
  /// `GET /api/v1/categories`), so the home carousel and categories screen can
  /// render from local storage when the server is unreachable. It is refreshed
  /// from the server on every successful first-page fetch.
  static const String appCategories = 'app_categories_box';

  /// Box storing the signed-in user's cached profile payload (from
  /// `GET /api/v1/user/profile`), so the profile header and personal-information
  /// screens can render from local storage when the server is unreachable. It is
  /// refreshed from the server on every successful profile fetch or update.
  static const String userProfile = 'user_profile_box';
}
