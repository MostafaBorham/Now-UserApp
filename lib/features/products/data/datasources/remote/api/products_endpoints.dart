
abstract class ProductsEndpoints {
  static String get getProductDetails =>
      '$getProducts/$productSlug';
  static const String getProducts = '/api/v1/products';
  static int? categoryId;
  static String productSlug = '';

  static Map<String, dynamic> getProductsQuery = <String, dynamic>{
    'sort': 'price',
    'direction' : 'asc',
    'category_id' : categoryId,
  };
}
