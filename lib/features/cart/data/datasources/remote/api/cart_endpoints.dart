
abstract class CartEndpoints {
  static const String getCart = '/api/v1/cart';
  static const String addToCart = '/api/v1/cart/items';


  static String cartProduct(int productId) =>
      '/api/v1/cart/items/$productId';



  static String cartVendor(int vendorId) =>
      '/api/v1/cart/vendors/$vendorId';



  static Map<String, dynamic> quantityBody(int quantity) => <String, dynamic>{
        'quantity': quantity,
      };

  static Map<String, dynamic> addToCartBody(int quantity,int productId) => <String, dynamic>{
    'quantity': quantity,
    'product_id': productId,
  };
}
