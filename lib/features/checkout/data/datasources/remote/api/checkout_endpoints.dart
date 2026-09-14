/// API endpoints owned by the checkout feature.
abstract class CheckoutEndpoints {
  /// Prepares a draft order group. The same endpoint backs both flows:
  /// - a `null` `vendor_id` drafts every store in the cart,
  /// - a concrete `vendor_id` drafts only that single store.
  static const String checkout = '/api/v1/checkout/cart/preview';

  /// Builds the draft request body. [vendorId] is `null` for the all-stores
  /// flow and a store id for the single-store flow; either way the key is sent
  /// so the server can distinguish the two cases explicitly.
  static Map<String, dynamic> checkoutBody({int? vendorId}) =>
      <String, dynamic>{'vendor_id': vendorId};

  /// Single-store checkout preview. Unlike [checkout], this endpoint scopes the
  /// preview to one vendor via the path and its response carries a single
  /// `vendor` with a top-level `products` list (not `vendor_groups`).
  /// [vendorId] identifies that store.
  static String checkoutForSingleStore(int vendorId) =>
      '/api/v1/checkout/vendor/$vendorId/preview';

  /// Stateless per-vendor coupon calculator. The server reads the user's own
  /// selected cart rows for the vendor, so the body carries only the vendor and
  /// the code — no cart/draft reference.
  static const String couponsApply = '/api/v1/coupons/apply';

  /// Stateless per-vendor purchase-voucher calculator. Same body shape as
  /// [couponsApply]; the voucher is identified by its code, not an id.
  static const String purchaseVouchersApply = '/api/v1/purchase-vouchers/apply';

  /// Shared body for [couponsApply] / [purchaseVouchersApply].
  static Map<String, dynamic> discountApplyBody({
    required int vendorId,
    required String code,
  }) => <String, dynamic>{'vendor_id': vendorId, 'code': code};

  /// Confirms a draft order group — the final checkout step, sending the
  /// address, tip, notes, payment method and coupons in one request.
  /// [orderGroupUuid] identifies the draft to confirm.
  static String confirmOrder(String orderGroupUuid) =>
      '/api/v1/checkout/cart/$orderGroupUuid';

  /// Builds the confirm-order request body. Only [addressId], [paymentMethod]
  /// and [deliveryInstructions] are always sent; the remaining optional fields
  /// are omitted when not provided so the server keeps whatever the draft
  /// already holds. [deliveryInstructions] carries the driver directions typed
  /// on the checkout screen and defaults to an empty string. [coupons] maps a
  /// vendor id to its coupon code and — JSON object keys must be strings — is
  /// serialized with the vendor ids in their string form.
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
