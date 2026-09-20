abstract class CartEndpoints {
  static const String getCart = '/api/v1/cart';
  static const String addToCart = '/api/v1/cart/items';

  static String cartProduct(int productId) => '/api/v1/cart/items/$productId';

  static String cartVendor(int vendorId) => '/api/v1/cart/vendors/$vendorId';

  /// The `cart_item_id` query that picks one line of a product; the path carries
  /// the product id. Empty when there is no line id, which falls back to the
  /// server's product-level behaviour.
  static Map<String, dynamic> cartItemQuery(int? cartItemId) =>
      <String, dynamic>{'cart_item_id': ?cartItemId};

  static Map<String, dynamic> quantityBody(int quantity) => <String, dynamic>{
    'quantity': quantity,
  };

  static Map<String, dynamic> addToCartBody(
    int quantity,
    int productId,
    Map<String, dynamic>? options,
  ) => <String, dynamic>{
    'quantity': quantity,
    'product_id': productId,
    'options': ?options,
  };
}
