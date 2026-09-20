/// API endpoints owned by the stores feature.
abstract class StoresEndpoints {
  static const int _perPage = 15;

  static String get getStoreDetails =>
      '$getStores/$storeId';
  static const String getStores = '/api/v1/stores';
  static const String getFeaturedStores = '$getStores/featured';
  static int? storeId;

  static Map<String, dynamic> storesQuery({
    required int page,
    String? search,
    int? categoryId,
    String? rating,
  }) =>
      <String, dynamic>{
        'per_page': _perPage,
        'page': page,
        'category_id': ?categoryId,
        if (rating != null && rating.isNotEmpty) 'rating': rating,
        if (search != null && search.isNotEmpty) 'search': search,
      };

  static String get getStoreCategoryProducts =>
      '/api/v1/stores/$storeId/products';

  static int? storeCategoryId;
  static String? productsSearch;
  static String? productsFilter;
  static int productsPerPage = 15;
  static int productsPage = 1;

  /// Query parameters for getStoreCategoryProducts
  static Map<String, dynamic> get getStoreCategoryProductsQuery => {
    'filter': productsFilter,
    'per_page': productsPerPage,
    'page': productsPage,
  };
}
