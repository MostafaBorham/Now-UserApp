
abstract class StoresEndpoints {
  static String get getStoreDetails =>
      '$getStores/$storeId';
  static const String getStores = '/api/v1/stores';
  static const String getFeaturedStores = '$getStores/featured';
  static int? storeId;

  static String get getStoreCategoryProducts =>
      '/api/v1/stores/$storeId/products';

  static int? storeCategoryId;
  static String? productsSearch;
  static String? productsFilter;
  static int productsPerPage = 15;
  static int productsPage = 1;


  static Map<String, dynamic> get getStoreCategoryProductsQuery => {
    'filter': productsFilter,
    'per_page': productsPerPage,
    'page': productsPage,
  };
}
