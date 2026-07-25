/// A coupon the user successfully applied to one vendor during checkout.
///
/// Kept as a flat list while the user shops the checkout screen (see
/// `appliedCouponsProvider`) and folded into the `vendor id → code` map that the
/// confirm-order request expects by `ConfirmOrderViewModel`.
class AppliedCouponModel {
  /// The vendor (store) the [code] was applied to.
  final int vendorId;

  /// The coupon code accepted by the server for [vendorId].
  final String code;

  const AppliedCouponModel({required this.vendorId, required this.code});
}
