/// API endpoints owned by the cart feature.
abstract class CartEndpoints {
  static const String getCart = '/api/v1/cart';
  static const String addToCart = '/api/v1/cart/items';

  /// A single cart line, identified by its product id.
  static String cartProduct(int productId) =>
      '/api/v1/cart/items/$productId';

  /// Body the cart-line endpoint expects: the new [quantity] (`0` removes the
  /// line).
  static Map<String, dynamic> quantityBody(int quantity) => <String, dynamic>{
        'quantity': quantity,
      };

  static Map<String, dynamic> addToCartBody(int quantity,int productId) => <String, dynamic>{
    'quantity': quantity,
    'product_id': productId,
  };
}
