










class VendorDiscountApplicationModel {
  final bool applied;
  final int? vendorId;
  final String? code;
  final String? currency;
  final double subtotal;
  final double discount;
  final double subtotalAfterDiscount;




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
