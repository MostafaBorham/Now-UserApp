/// API endpoints owned by the stores feature.
abstract class StoresEndpoints {
  static String get getStoreDetails =>
      '$getStores/$storeId';
  static const String getStores = '/api/v1/stores';
  static int? storeId;

  static String get getStoreCategoryProducts =>
      '/api/v1/stores/$storeId/products';

  static int? storeCategoryId;
  static String? productsSearch;
  static int productsPerPage = 15;

  /// Query parameters for getStoreCategoryProducts
  static Map<String, dynamic> get getStoreCategoryProductsQuery => {
    'category_ids[]': storeCategoryId,
  };
}
