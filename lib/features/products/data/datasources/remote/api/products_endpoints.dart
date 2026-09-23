/// API endpoints owned by the products feature.
abstract class ProductsEndpoints {
  static const String getProducts = '/api/v1/products';

  static String productDetails(String slug) =>
      '$getProducts/${Uri.encodeComponent(slug)}';

  static const int _perPage = 15;

  static Map<String, dynamic> getProductsQuery({
    required int page,
    String? search,
  }) => <String, dynamic>{
    'per_page': _perPage,
    'page': page,
    'sort': 'price',
    'direction': 'asc',
    if (search != null && search.isNotEmpty) 'search': search,
  };
}
