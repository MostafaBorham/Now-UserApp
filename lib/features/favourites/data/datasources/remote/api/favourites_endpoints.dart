
abstract class FavouritesEndpoints {
  static const int _perPage = 15;



  static const String getFavourites = '/api/v1/favorites';


  static const String getFavouriteCategories = '/api/v1/favorites/categories';





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


  static Map<String, dynamic> getFavouriteCategoriesQuery({
    required String type,
  }) => {'type': type};

  static const String addToFavourites = '/api/v1/favorites';


  static Map<String, dynamic> addProductToFavouritesBody({
    required int productId,
  }) => {
        'type': 'product',
        'id': productId,
      };


  static Map<String, dynamic> addStoreToFavouritesBody({
    required int storeId,
  }) => {
    'type': 'vendor',
    'id': storeId,
  };


  static String removeProductFromFavourites({required int productId}) =>
      '/api/v1/favorites/product/$productId';


  static String removeStoreFromFavourites({required int storeId}) =>
      '/api/v1/favorites/vendor/$storeId';
}
