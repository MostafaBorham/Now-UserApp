/// API endpoints owned by the favourites feature.
abstract class FavouritesEndpoints {
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
}
