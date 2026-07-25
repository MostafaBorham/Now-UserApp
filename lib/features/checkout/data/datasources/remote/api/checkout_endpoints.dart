/// API endpoints owned by the checkout feature.
abstract class CheckoutEndpoints {
  /// Prepares a draft order group. The same endpoint backs both flows:
  /// - a `null` `vendor_id` drafts every store in the cart,
  /// - a concrete `vendor_id` drafts only that single store.
  static const String checkout = '/api/v1/checkout/draft';

  /// Builds the draft request body. [vendorId] is `null` for the all-stores
  /// flow and a store id for the single-store flow; either way the key is sent
  /// so the server can distinguish the two cases explicitly.
  static Map<String, dynamic> checkoutBody({int? vendorId}) => <String, dynamic>{
        'vendor_id': vendorId,
      };

  /// Applies coupon codes to an existing draft order group and returns the same
  /// shape as [checkout]. [orderGroupUuid] identifies the draft to update.
  static String draftCoupons(String orderGroupUuid) =>
      '/api/v1/checkout/draft/$orderGroupUuid';

  /// Builds the coupons request body. [coupons] maps a vendor id to the coupon
  /// code applied for that vendor; JSON object keys must be strings, so the
  /// vendor ids are serialized as their string form.
  static Map<String, dynamic> draftCouponsBody({
    required Map<int, String> coupons,
  }) =>
      <String, dynamic>{
        'coupons': coupons.map(
          (int vendorId, String couponCode) =>
              MapEntry<String, String>('$vendorId', couponCode),
        ),
      };

  /// Confirms a draft order group — the final checkout step, sending the
  /// address, tip, notes, payment method and coupons in one request.
  /// Shares the draft resource path with [draftCoupons]; [orderGroupUuid]
  /// identifies the draft to confirm.
  static String confirmOrder(String orderGroupUuid) =>
      '/api/v1/checkout/draft/$orderGroupUuid';

  /// Builds the confirm-order request body. Only [addressId] and
  /// [paymentMethod] are always sent; the optional fields are omitted when not
  /// provided so the server keeps whatever the draft already holds. [coupons]
  /// maps a vendor id to its coupon code and — JSON object keys must be
  /// strings — is serialized with the vendor ids in their string form.
  static Map<String, dynamic> confirmOrderBody({
    required int addressId,
    required String paymentMethod,
    double? driverTip,
    String? notes,
    Map<int, String>? coupons,
  }) =>
      <String, dynamic>{
        'address_id': addressId,
        'payment_method': paymentMethod,
        'driver_tip': ?driverTip,
        'notes': ?notes,
        if (coupons != null && coupons.isNotEmpty)
          'coupons': coupons.map(
            (int vendorId, String couponCode) =>
                MapEntry<String, String>('$vendorId', couponCode),
          ),
      };
}
