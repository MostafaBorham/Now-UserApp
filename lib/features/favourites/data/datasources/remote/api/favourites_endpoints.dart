/// API endpoints owned by the favourites feature.
abstract class FavouritesEndpoints {
  static const int _perPage = 15;

  /// List the caller's favourites, one page at a time. Same path for products
  /// and stores — the `type` query narrows it to a single tab.
  static const String getFavourites = '/api/v1/favorites';

  /// Category chip row for the list screen, scoped to a tab via `type`.
  static const String getFavouriteCategories = '/api/v1/favorites/categories';

  /// Query for [getFavourites]. [type] is the API discriminator (`product` /
  /// `vendor`), so each tab asks only for its own kind. [search], [categoryIds]
  /// and [sort] are the filter chrome — each omitted from the query when unset,
  /// so the backend applies its own defaults.
  static Map<String, dynamic> getFavouritesQuery({
    required String type,
    required int page,
    String? search,
    List<int>? categoryIds,
    String? sort,
  }) => {
        'type': type,
        'per_page': _perPage,
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryIds != null && categoryIds.isNotEmpty)
          'category_ids': categoryIds,
        'sort': ?sort,
      };

  /// Query for [getFavouriteCategories].
  static Map<String, dynamic> getFavouriteCategoriesQuery({
    required String type,
  }) => {'type': type};

  static const String addToFavourites = '/api/v1/favorites';

  /// Body for [addToFavourites] when adding a product.
  static Map<String, dynamic> addProductToFavouritesBody({
    required int productId,
  }) => {
        'type': 'product',
        'id': productId,
      };

  /// Body for [addToFavourites] when adding a Store.
  static Map<String, dynamic> addStoreToFavouritesBody({
    required int storeId,
  }) => {
    'type': 'vendor',
    'id': storeId,
  };

  /// Path for removing a product from favourites.
  static String removeProductFromFavourites({required int productId}) =>
      '/api/v1/favorites/product/$productId';

  /// Path for removing a store (vendor) from favourites.
  static String removeStoreFromFavourites({required int storeId}) =>
      '/api/v1/favorites/vendor/$storeId';
}
