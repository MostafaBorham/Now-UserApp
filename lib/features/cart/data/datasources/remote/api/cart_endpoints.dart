/// API endpoints owned by the cart feature.
abstract class CartEndpoints {
  static const String getCart = '/api/v1/cart';

  /// Removes a single cart line, identified by its product id.
  static String deleteCartProduct(int productId) =>
      '/api/v1/cart/items/$productId';

  /// Static body the delete-item endpoint always expects.
  static const Map<String, dynamic> deleteCartProductBody = <String, dynamic>{
    'quantity': 0,
  };
}
