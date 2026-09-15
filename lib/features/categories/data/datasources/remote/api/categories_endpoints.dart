




abstract class CategoriesEndpoints {
  static const int _perPage = 15;

  static const String getAppCategories = '/api/v1/categories/tree';

  static String categoryStores(String categorySlug) =>
      '/api/v1/categories/$categorySlug/stores';

  static String categoryProducts(String categorySlug) =>
      '/api/v1/categories/$categorySlug/products';

  static Map<String, dynamic> appCategoriesQuery(int page, {String? search}) => {
    'max_depth': 1,
    'per_page': 100,
    'page': page,
    if (search != null && search.isNotEmpty) 'search': search,
  };

  static Map<String, dynamic> categoryStoresQuery({
    required int page,
    int? categoryId,
    String? search,
  }) => {
    'per_page': _perPage,
    'page': page,
    'category_id': categoryId,
    if (search != null && search.isNotEmpty) 'search': search,
  };

  static Map<String, dynamic> categoryProductsQuery({
    required int page,
    int? categoryId,
    String? search,
  }) => {
    'per_page': _perPage,
    'page': page,
    'sort': 'price',
    'direction': 'asc',
    'category_id': categoryId,
    if (search != null && search.isNotEmpty) 'search': search,
  };
}
