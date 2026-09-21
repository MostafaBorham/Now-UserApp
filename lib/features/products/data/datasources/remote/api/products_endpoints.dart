/// API endpoints owned by the products feature.
abstract class ProductsEndpoints {
  static const String getProducts = '/api/v1/products';

  static String productDetails(String slug) =>
      '$getProducts/${Uri.encodeComponent(slug)}';

  static Map<String, dynamic> getProductsQuery({String? search}) =>
      <String, dynamic>{
        'sort': 'price',
        'direction': 'asc',
        if (search != null && search.isNotEmpty) 'search': search,
      };
}
