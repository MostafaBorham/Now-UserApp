import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';

/// API endpoints owned by the checkout feature.
///
/// Checkout has no drafts: preview only prices, and place prices again, charges
/// and creates the orders in one request. Both come in a cart flavour (every
/// store in the cart) and a vendor flavour (one store) — a `null` vendor id
/// picks the cart one.
abstract class CheckoutEndpoints {
  /// Prices the checkout without creating or reserving anything.
  static String preview(int? vendorId) => vendorId == null
      ? '/api/v1/checkout/cart/preview'
      : '/api/v1/checkout/vendor/$vendorId/preview';

  /// Places the order and removes the purchased rows from the cart.
  ///
  /// The cart flavour buys every selected row of **every** store, so checking
  /// out a single store must go through the vendor one.
  static String place(int? vendorId) => vendorId == null
      ? '/api/v1/checkout/cart'
      : '/api/v1/checkout/vendor/$vendorId';

  /// Stateless per-vendor coupon calculator. The server reads the user's own
  /// selected cart rows for the vendor, so the body carries only the vendor and
  /// the code.
  static const String couponsApply = '/api/v1/coupons/apply';

  /// Stateless per-vendor purchase-voucher calculator. Same body shape as
  /// [couponsApply]; the voucher is identified by its code, not an id.
  static const String purchaseVouchersApply = '/api/v1/purchase-vouchers/apply';

  /// Shared body for [couponsApply] / [purchaseVouchersApply].
  static Map<String, dynamic> discountApplyBody({
    required int vendorId,
    required String code,
  }) => <String, dynamic>{'vendor_id': vendorId, 'code': code};

  /// The pricing choices [preview] and [place] both take, so what the invoice
  /// shows and what the order is charged are priced from the same input.
  ///
  /// Coupons travel as one `coupon` on the vendor endpoints and as a
  /// `vendor id → code` map (`coupon_codes`) on the cart ones; a purchase
  /// voucher is a single `voucher` either way. The coupons are sorted and a
  /// zero tip is left out (the server's default), so the same choices always
  /// encode the same way — the place body doubles as the idempotency
  /// fingerprint.
  static Map<String, dynamic> pricingBody({
    int? vendorId,
    int? addressId,
    double driverTip = 0,
    List<AppliedDiscountModel> discounts = const <AppliedDiscountModel>[],
  }) {
    final List<AppliedDiscountModel> coupons =
        discounts.where((AppliedDiscountModel d) => !d.isVoucher).toList()
          ..sort(
            (AppliedDiscountModel a, AppliedDiscountModel b) =>
                a.vendorId.compareTo(b.vendorId),
          );
    final String? voucher = discounts
        .where((AppliedDiscountModel d) => d.isVoucher)
        .firstOrNull
        ?.code;

    return <String, dynamic>{
      'address_id': ?addressId,
      if (driverTip > 0) 'driver_tip': driverTip,
      if (vendorId != null)
        'coupon': ?coupons
            .where((AppliedDiscountModel d) => d.vendorId == vendorId)
            .firstOrNull
            ?.code
      else if (coupons.isNotEmpty)
        'coupon_codes': <String, String>{
          for (final AppliedDiscountModel d in coupons) '${d.vendorId}': d.code,
        },
      'voucher': ?voucher,
    };
  }

  /// The [place] body: the [pricingBody] plus how it is paid.
  ///
  /// `payment_method_id` rides only with the `card` method — the backend
  /// prohibits it for wallet/cod — so callers pass it null otherwise.
  static Map<String, dynamic> placeBody({
    int? vendorId,
    required int addressId,
    required String paymentMethod,
    int? paymentMethodId,
    double driverTip = 0,
    String deliveryInstructions = '',
    List<AppliedDiscountModel> discounts = const <AppliedDiscountModel>[],
  }) => <String, dynamic>{
    ...pricingBody(
      vendorId: vendorId,
      addressId: addressId,
      driverTip: driverTip,
      discounts: discounts,
    ),
    'delivery_instructions': deliveryInstructions,
    'payment_method': paymentMethod,
    'payment_method_id': ?paymentMethodId,
  };
}
