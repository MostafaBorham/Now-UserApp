/// API endpoints owned by the categories feature.
abstract class CategoriesEndpoints {
  static const String getAppCategories = '/api/v1/categories/tree';
  static const String getProductSubCategories = '/api/v1/categories/tree';
  static const String getStoreSubCategories = '/api/v1/categories/tree';

  static String get getCategoryStores =>
      '/api/v1/categories/$appCategorySlug/stores';

  static String get getCategoryProducts =>
      '/api/v1/categories/$appCategorySlug/products';

  static String appCategorySlug = '';
  static int? categoryId;
  static String? search;
  static int perPage = 15;
  static int page = 1;

  /// Query parameters for getAppCategories
  static const Map<String, dynamic> getAppCategoriesQuery = {
    'max_depth': 1,
  };

  /// Query parameters for getProductSubCategories
  static const Map<String, dynamic> getProductSubCategoriesQuery = {
    'max_depth': 1,
  };

  /// Query parameters for getStoreSubCategories
  static const Map<String, dynamic> getStoreSubCategoriesQuery = {
    'max_depth': 1,
  };

  /// Query parameters for getCategoryStores
  static Map<String, dynamic> get getCategoryStoresQuery => {
    'search': search,
    'per_page': perPage,
    'page': page,
    'category_id': categoryId,
  };

  /// Query parameters for getCategoryProducts
  static Map<String, dynamic> get getCategoryProductsQuery => {
    'search': search,
    'per_page': perPage,
    'page': page,
    'sort': 'price',
    'direction': 'asc',
    'category_id': categoryId,
  };
}