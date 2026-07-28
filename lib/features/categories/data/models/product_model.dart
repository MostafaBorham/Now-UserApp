import 'package:nowdelivery_user_app/features/categories/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

class ProductModel {
  final int? id;
  final int? productId;
  final int? categoryId;

  /// Localized product name as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(name)`.
  final Map<String, dynamic>? name;
  final String? slug;
  final String? sku;

  /// Localized short description as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(shortDescription)`.
  final Map<String, dynamic>? shortDescription;

  /// Localized description as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(description)`.
  final Map<String, dynamic>? description;
  final double? price;
  final double? effectivePrice;
  final double? dealDiscountAmount;
  final double? comparePrice;
  final int? stock;
  final bool? inStock;
  final String? status;
  final bool? isFeatured;
  final String? publishedAt;
  final String? metaTitle;
  final String? metaDescription;
  final String? searchKeywords;
  final String? primaryImage;
  final List<String>? images;
  final bool? hasVariants;
  // final CategoryModel? category;
  final StoreModel? vendor;
  final String? createdAt;
  final String? updatedAt;
  final String? imageUrl;
  final ActiveDealModel? activeDeal;

  /// Cart-line state — only present when the product comes from the cart
  /// endpoint (`GET /api/v1/cart`); `null` everywhere else.
  final int? quantity;
  final bool? isSelected;

  const ProductModel({
    this.id,
    this.productId,
    this.categoryId,
    this.name,
    this.slug,
    this.sku,
    this.shortDescription,
    this.description,
    this.price,
    this.effectivePrice,
    this.dealDiscountAmount,
    this.comparePrice,
    this.stock,
    this.inStock,
    this.status,
    this.isFeatured,
    this.publishedAt,
    this.metaTitle,
    this.metaDescription,
    this.searchKeywords,
    this.primaryImage,
    this.images,
    this.hasVariants,
    // this.category,
    this.vendor,
    this.createdAt,
    this.updatedAt,
    this.activeDeal,
    this.quantity,
    this.isSelected,
    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      categoryId: json['category_id'] as int?,
      name: (json['name'] is String)
          ? {'ar': json['name'] as String, 'en': json['name'] as String}
          : json['name'],
      slug: json['slug'] as String?,
      sku: json['sku'] as String?,
      activeDeal: json['active_deal'] == null
          ? null
          : ActiveDealModel.fromJson(json['active_deal']),
      // shortDescription: json['short_description'],
      // description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      effectivePrice: (json['effective_price'] as num?)?.toDouble(),
      dealDiscountAmount: (json['deal_discount_amount'] as num?)?.toDouble(),
      comparePrice:
          double.tryParse(json['compare_price']?.toString() ?? '') ?? 0.0,
      stock: (json['stock'] as num?)?.toInt(),
      inStock: json['in_stock'] as bool?,
      status: json['status'] as String?,
      isFeatured: json['is_featured'] as bool?,
      publishedAt: json['published_at'] as String?,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      searchKeywords: json['search_keywords'] as String?,
      primaryImage: json['primary_image'] as String?,
      imageUrl: json['image_url'] as String?,
      images: json['images'] == null ? null : List<String>.from(json['images']),
      hasVariants: json['has_variants'] as bool?,
      /*      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category']),*/
      vendor: json['vendor'] == null
          ? null
          : StoreModel.fromJson(json['vendor']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      isSelected: json['is_selected'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
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
      'published_at': publishedAt,
      'active_deal': activeDeal?.toJson(),
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'search_keywords': searchKeywords,
      'primary_image': primaryImage,
      'image_url': imageUrl,
      'images': images,
      'has_variants': hasVariants,
      // 'category': category?.toJson(),
      'vendor': vendor?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'quantity': quantity,
      'is_selected': isSelected,
    };
  }
}
