/// API endpoints owned by the cart feature.
abstract class CartEndpoints {
  static const String getCart = '/api/v1/cart';
  static int productQuantity = 0;

  /// Removes a single cart line, identified by its product id.
  static String cartProduct(int productId) =>
      '/api/v1/cart/items/$productId';

  /// Static body the delete-item endpoint always expects.
  static Map<String, dynamic> updateQuantityToCartProductBody = <String, dynamic>{
    'quantity': productQuantity,
  };
}
