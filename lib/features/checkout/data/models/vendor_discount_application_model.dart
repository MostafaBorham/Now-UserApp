/// Result of a stateless per-vendor discount calculation — the response `data`
/// of both `POST /api/v1/coupons/apply` and
/// `POST /api/v1/purchase-vouchers/apply` (identical shape).
///
/// A request can succeed (HTTP 200) while the code itself is rejected: then
/// [applied] is `false`, [discount] is `0`, and [reason] explains why. Callers
/// must check [applied] rather than the status code.
///
/// Money fields arrive as decimal strings (e.g. `"12.50"`) and are parsed to
/// doubles here. The endpoint returns only this vendor's coupon subtotal and
/// discount — never tax, delivery, or an order grand total.
class VendorDiscountApplicationModel {
  final bool applied;
  final int? vendorId;
  final String? code;
  final String? currency;
  final double subtotal;
  final double discount;
  final double subtotalAfterDiscount;

  /// Rejection reason when [applied] is `false`. Human-readable for coupons;
  /// for vouchers the backend returns a raw untranslated key, so callers must
  /// not display it — show a generic message instead.
  final String? reason;

  const VendorDiscountApplicationModel({
    this.applied = false,
    this.vendorId,
    this.code,
    this.currency,
    this.subtotal = 0,
    this.discount = 0,
    this.subtotalAfterDiscount = 0,
    this.reason,
  });

  factory VendorDiscountApplicationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const VendorDiscountApplicationModel();
    }

    return VendorDiscountApplicationModel(
      applied: json['applied'] as bool? ?? false,
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      code: json['code']?.toString(),
      currency: json['currency']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      subtotalAfterDiscount:
          double.tryParse(json['subtotal_after_discount']?.toString() ?? '') ??
          0.0,
      reason: json['reason']?.toString(),
    );
  }
}
