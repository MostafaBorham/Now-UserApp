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

  /// Box storing the signed-in user's cached saved payment cards (from
  /// `GET /api/v1/payment-methods/cards`), so the my-cards sheet can render from
  /// local storage when the server is unreachable. It is refreshed from the
  /// server on every successful cards fetch.
  static const String myCards = 'my_cards_box';

  /// Box storing the signed-in user's cached wallet payload (from
  /// `GET /api/v1/wallet`), so the wallet screen can render the last-known
  /// balance and top-up limits when the server is unreachable. It is refreshed
  /// from the server on every successful wallet fetch.
  static const String walletInfo = 'wallet_info_box';

  /// Box storing the signed-in user's unresolved wallet top-up attempt — the
  /// amount, card and idempotency key of a submit whose outcome isn't known yet.
  /// Unlike the other boxes this is not a cache: cancelling a request or killing
  /// the app does not cancel the attempt server-side, so the record has to
  /// outlive the process or a retry would mint a new key and charge twice.
  /// Cleared the moment the server confirms the top-up.
  static const String walletTopUpAttempt = 'wallet_top_up_attempt_box';

  /// Box storing the cached home feed payload (the `sections` list from
  /// `GET /api/v1/home-sections`), so the home screen can render its last-seen
  /// content when the server is unreachable. It is refreshed from the server on
  /// every successful feed fetch.
  static const String homeSections = 'home_sections_box';

  /// Box storing the cached home header banners payload (the `banners` list from
  /// `GET /api/v1/banners`), so the home top-banner carousel can render from
  /// local storage when the server is unreachable. It is refreshed from the
  /// server on every successful banners fetch.
  static const String headerBanners = 'header_banners_box';

  /// Box storing the cached first page of the featured stores list (from
  /// `GET /stores/featured`), so the home "Best brands" carousel can render from
  /// local storage when the server is unreachable. It is refreshed from the
  /// server on every successful first-page fetch.
  static const String featuredStores = 'featured_stores_box';
}
