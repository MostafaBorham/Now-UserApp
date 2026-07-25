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
}
