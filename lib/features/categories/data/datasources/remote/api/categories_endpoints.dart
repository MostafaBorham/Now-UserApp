/// API endpoints owned by the categories feature.
///
/// Paths and query maps are built from the caller's arguments — the class holds
/// no request state of its own, so concurrent requests (e.g. the Products and
/// Stores tabs paging at the same time) can't clobber each other.
abstract class CategoriesEndpoints {
  static const int _perPage = 15;

  static const String getAppCategories = '/api/v1/categories/tree';

  static String categoryStores(String categorySlug) =>
      '/api/v1/categories/$categorySlug/stores';

  static String categoryProducts(String categorySlug) =>
      '/api/v1/categories/$categorySlug/products';

  static Map<String, dynamic> appCategoriesQuery(int page) => {
    'max_depth': 1,
    'per_page': _perPage,
    'page': page,
  };

  static Map<String, dynamic> categoryStoresQuery({
    required int page,
    int? categoryId,
  }) => {
    'per_page': _perPage,
    'page': page,
    'category_id': categoryId,
  };

  static Map<String, dynamic> categoryProductsQuery(int page) => {
    'per_page': _perPage,
    'page': page,
    'sort': 'price',
    'direction': 'asc',
  };
}
