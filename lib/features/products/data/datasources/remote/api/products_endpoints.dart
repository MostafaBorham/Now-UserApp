/// API endpoints owned by the products feature.
abstract class ProductsEndpoints {
  static String get getProductDetails =>
      '$getProducts/$productSlug';
  static const String getProducts = '/api/v1/products';
  static String productSlug = '';

  static Map<String, dynamic> getProductsQuery({String? search}) =>
      <String, dynamic>{
        'sort': 'price',
        'direction': 'asc',
        if (search != null && search.isNotEmpty) 'search': search,
      };
}
