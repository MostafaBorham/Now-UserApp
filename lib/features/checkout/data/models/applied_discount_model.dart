/// A discount the user successfully applied to one vendor during checkout —
/// either a coupon or a purchase voucher.
///
/// Held as a flat, one-slot-per-vendor list while the user shops the checkout
/// screen (see `appliedDiscountsProvider`). The single slot per vendor is what
/// enforces coupon/voucher mutual exclusivity: applying either replaces the
/// vendor's slot, and a voucher also clears every other vendor's coupon. The
/// preview and place requests fold the list into the
/// coupon(s) and the single voucher they take (see
/// `CheckoutEndpoints.pricingBody`).
class AppliedDiscountModel {
  /// The vendor (store) the [code] was applied to.
  final int vendorId;

  /// The coupon/voucher code accepted by the server for [vendorId].
  final String code;

  /// `true` for a purchase voucher, `false` for a coupon.
  final bool isVoucher;

  const AppliedDiscountModel({
    required this.vendorId,
    required this.code,
    this.isVoucher = false,
  });
}
