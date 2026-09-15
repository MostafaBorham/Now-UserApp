
abstract class CheckoutEndpoints {



  static const String checkout = '/api/v1/checkout/cart/preview';




  static Map<String, dynamic> checkoutBody({int? vendorId}) =>
      <String, dynamic>{'vendor_id': vendorId};





  static String checkoutForSingleStore(int vendorId) =>
      '/api/v1/checkout/vendor/$vendorId/preview';




  static const String couponsApply = '/api/v1/coupons/apply';



  static const String purchaseVouchersApply = '/api/v1/purchase-vouchers/apply';


  static Map<String, dynamic> discountApplyBody({
    required int vendorId,
    required String code,
  }) => <String, dynamic>{'vendor_id': vendorId, 'code': code};




  static String confirmOrder(String orderGroupUuid) =>
      '/api/v1/checkout/cart/$orderGroupUuid';








  static Map<String, dynamic> confirmOrderBody({
    int? addressId,
    String? paymentMethod,
    double? driverTip,
    String? notes,
    String? deliveryInstructions,
    Map<int, String>? coupons,
  }) => <String, dynamic>{
    'address_id': addressId,
    'driver_tip': ?driverTip,
    'notes': ?notes,
    'delivery_instructions': deliveryInstructions ?? '',
    'payment_method': paymentMethod ?? 'wallet',
    if (coupons != null && coupons.isNotEmpty)
      'coupons': coupons.map(
        (int vendorId, String couponCode) =>
            MapEntry<String, String>('$vendorId', couponCode),
      ),
  };
}
