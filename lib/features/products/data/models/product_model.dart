class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String sku;
  final String shortDescription;
  final String description;
  final double price;
  final double effectivePrice;
  final double dealDiscountAmount;
  final double comparePrice;
  final int stock;
  final bool inStock;
  final String status;
  final bool isFeatured;
  final ActiveDealModel? activeDeal;
  final String? publishedAt;
  final String metaTitle;
  final String metaDescription;
  final String searchKeywords;
  final String? primaryImage;
  final List<String> images;
  final bool hasVariants;
  final List<dynamic> variants;
  final CategoryModel category;
  final dynamic vendor;
  final String createdAt;
  final String updatedAt;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.sku,
    required this.shortDescription,
    required this.description,
    required this.price,
    required this.effectivePrice,
    required this.dealDiscountAmount,
    required this.comparePrice,
    required this.stock,
    required this.inStock,
    required this.status,
    required this.isFeatured,
    this.activeDeal,
    this.publishedAt,
    required this.metaTitle,
    required this.metaDescription,
    required this.searchKeywords,
    this.primaryImage,
    required this.images,
    required this.hasVariants,
    required this.variants,
    required this.category,
    this.vendor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      slug: json['slug'],
      sku: json['sku'],
      shortDescription: json['short_description'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      effectivePrice: (json['effective_price'] as num).toDouble(),
      dealDiscountAmount: (json['deal_discount_amount'] as num).toDouble(),
      comparePrice: (json['compare_price'] as num).toDouble(),
      stock: json['stock'],
      inStock: json['in_stock'],
      status: json['status'],
      isFeatured: json['is_featured'],
      activeDeal: json['active_deal'] == null
          ? null
          : ActiveDealModel.fromJson(json['active_deal']),
      publishedAt: json['published_at'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      searchKeywords: json['search_keywords'],
      primaryImage: json['primary_image'],
      images: List<String>.from(json['images'] ?? []),
      hasVariants: json['has_variants'],
      variants: List<dynamic>.from(json['variants'] ?? []),
      category: CategoryModel.fromJson(json['category']),
      vendor: json['vendor'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'sku': sku,
      'short_description': shortDescription,
      'description': description,
      'price': price,
      'effective_price': effectivePrice,
      'deal_discount_amount': dealDiscountAmount,
      'compare_price': comparePrice,
      'stock': stock,
      'in_stock': inStock,
      'status': status,
      'is_featured': isFeatured,
      'active_deal': activeDeal?.toJson(),
      'published_at': publishedAt,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'search_keywords': searchKeywords,
      'primary_image': primaryImage,
      'images': images,
      'has_variants': hasVariants,
      'variants': variants,
      'category': category.toJson(),
      'vendor': vendor,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ActiveDealModel {
  final int id;
  final String uuid;
  final String name;
  final String discountType;
  final double discountValue;
  final String scope;
  final int priority;
  final String status;
  final String startsAt;
  final String endsAt;

  const ActiveDealModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.scope,
    required this.priority,
    required this.status,
    required this.startsAt,
    required this.endsAt,
  });

  factory ActiveDealModel.fromJson(Map<String, dynamic> json) {
    return ActiveDealModel(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      discountType: json['discount_type'],
      discountValue: (json['discount_value'] as num).toDouble(),
      scope: json['scope'],
      priority: json['priority'],
      status: json['status'],
      startsAt: json['starts_at'],
      endsAt: json['ends_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'discount_type': discountType,
      'discount_value': discountValue,
      'scope': scope,
      'priority': priority,
      'status': status,
      'starts_at': startsAt,
      'ends_at': endsAt,
    };
  }
}

class CategoryModel {
  final int id;
  final CategoryNameModel name;
  final String slug;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: CategoryNameModel.fromJson(json['name']),
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name.toJson(), 'slug': slug};
  }
}

class CategoryNameModel {
  final String ar;
  final String en;

  const CategoryNameModel({required this.ar, required this.en});

  factory CategoryNameModel.fromJson(Map<String, dynamic> json) {
    return CategoryNameModel(ar: json['ar'], en: json['en']);
  }

  Map<String, dynamic> toJson() {
    return {'ar': ar, 'en': en};
  }
}