/// API endpoints owned by the categories feature.
abstract class CategoriesEndpoints {
  static const String getCategories = '/api/v1/categories/tree';
  static String get categoryStores => '/api/v1/categories/$categorySlug/stores';
  static String categorySlug = '';
  static String search = '';
  static int perPage = 15;
  static int page = 1;
  /// Query parameters for [getCategories]: only root categories + one level.
  static const Map<String, dynamic> getCategoriesQuery = <String, dynamic>{
    'max_depth': 1,
  };

  static Map<String, dynamic> getCategoryStoresQuery = <String, dynamic>{
    'search': search,
    'per_page' : perPage,
    'page' : page
  };
}
