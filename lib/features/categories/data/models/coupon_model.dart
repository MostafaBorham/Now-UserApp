class CouponModel {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final String? discountType;
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
    this.discountType,
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
      discountType: json['discount_type']?.toString(),
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
      'discount_type': discountType,
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
    String? discountType,
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
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
