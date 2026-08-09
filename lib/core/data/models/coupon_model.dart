class CouponModel {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final bool? isPercentage;
  final double? discountValue;
  final double? maxDiscountAmount;
  final double? minOrderValue;
  final String? startsAt;
  final String? expiresAt;

  const CouponModel({
    this.id,
    this.code,
    this.name,
    this.description,
    this.isPercentage = true,
    this.discountValue,
    this.maxDiscountAmount,
    this.minOrderValue,
    this.startsAt,
    this.expiresAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CouponModel();
    }

    return CouponModel(
      id: (json['id'] as num?)?.toInt(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      isPercentage: json['discount_type']?.toString() == 'percentage',
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      minOrderValue: (json['min_order_value'] as num?)?.toDouble(),
      startsAt: json['starts_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'discount_type': isPercentage == true ? 'percentage' : 'fixed',
      'discount_value': discountValue,
      'max_discount_amount': maxDiscountAmount,
      'min_order_value': minOrderValue,
      'starts_at': startsAt,
      'expires_at': expiresAt,
    };
  }

  CouponModel copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    bool? isPercentage,
    double? discountValue,
    double? maxDiscountAmount,
    double? minOrderValue,
    String? startsAt,
    String? expiresAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      isPercentage: isPercentage ?? this.isPercentage,
      discountValue: discountValue ?? this.discountValue,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
