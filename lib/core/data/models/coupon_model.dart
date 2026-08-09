class CouponModel {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final bool? isPercentage;
  final double? discountValue;
  final double? maxDiscountAmount;
  final double? minOrderValue;
  final int? usageLimit;
  final int? usageLimitPerUser;
  final bool? excludeDiscountedProducts;
  final int? usedCount;
  final bool? isActive;
  final String? status;
  final String? reviewStatus;
  final String? rejectionReason;
  final String? type;
  final int? vendorId;
  final int? cityId;
  final int? createdBy;
  final String? createdByType;
  final String? startsAt;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;
  final List<int> categoryIds;
  final List<dynamic> categories;
  final List<int> productIds;
  final List<dynamic> products;

  const CouponModel({
    this.id,
    this.code,
    this.name,
    this.description,
    this.isPercentage = true,
    this.discountValue,
    this.maxDiscountAmount,
    this.minOrderValue,
    this.usageLimit,
    this.usageLimitPerUser,
    this.excludeDiscountedProducts,
    this.usedCount,
    this.isActive,
    this.status,
    this.reviewStatus,
    this.rejectionReason,
    this.type,
    this.vendorId,
    this.cityId,
    this.createdBy,
    this.createdByType,
    this.startsAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.categoryIds = const <int>[],
    this.categories = const <dynamic>[],
    this.productIds = const <int>[],
    this.products = const <dynamic>[],
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
      usageLimit: (json['usage_limit'] as num?)?.toInt(),
      usageLimitPerUser: (json['usage_limit_per_user'] as num?)?.toInt(),
      excludeDiscountedProducts: json['exclude_discounted_products'] as bool?,
      usedCount: (json['used_count'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
      status: json['status']?.toString(),
      reviewStatus: json['review_status']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      type: json['type']?.toString(),
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      cityId: (json['city_id'] as num?)?.toInt(),
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByType: json['created_by_type']?.toString(),
      startsAt: json['starts_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      categoryIds:
          (json['category_ids'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic e) => (e as num).toInt())
              .toList(),
      categories: json['categories'] as List<dynamic>? ?? <dynamic>[],
      productIds:
          (json['product_ids'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic e) => (e as num).toInt())
              .toList(),
      products: json['products'] as List<dynamic>? ?? <dynamic>[],
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
      'usage_limit': usageLimit,
      'usage_limit_per_user': usageLimitPerUser,
      'exclude_discounted_products': excludeDiscountedProducts,
      'used_count': usedCount,
      'is_active': isActive,
      'status': status,
      'review_status': reviewStatus,
      'rejection_reason': rejectionReason,
      'type': type,
      'vendor_id': vendorId,
      'city_id': cityId,
      'created_by': createdBy,
      'created_by_type': createdByType,
      'starts_at': startsAt,
      'expires_at': expiresAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category_ids': categoryIds,
      'categories': categories,
      'product_ids': productIds,
      'products': products,
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
    int? usageLimit,
    int? usageLimitPerUser,
    bool? excludeDiscountedProducts,
    int? usedCount,
    bool? isActive,
    String? status,
    String? reviewStatus,
    String? rejectionReason,
    String? type,
    int? vendorId,
    int? cityId,
    int? createdBy,
    String? createdByType,
    String? startsAt,
    String? expiresAt,
    String? createdAt,
    String? updatedAt,
    List<int>? categoryIds,
    List<dynamic>? categories,
    List<int>? productIds,
    List<dynamic>? products,
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
      usageLimit: usageLimit ?? this.usageLimit,
      usageLimitPerUser: usageLimitPerUser ?? this.usageLimitPerUser,
      excludeDiscountedProducts:
          excludeDiscountedProducts ?? this.excludeDiscountedProducts,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      type: type ?? this.type,
      vendorId: vendorId ?? this.vendorId,
      cityId: cityId ?? this.cityId,
      createdBy: createdBy ?? this.createdBy,
      createdByType: createdByType ?? this.createdByType,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryIds: categoryIds ?? this.categoryIds,
      categories: categories ?? this.categories,
      productIds: productIds ?? this.productIds,
      products: products ?? this.products,
    );
  }
}
