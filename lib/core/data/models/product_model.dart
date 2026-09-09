import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/products/data/models/rating_model.dart';

class ProductModel {
  final int? id;
  final int? productId;
  final int? categoryId;
  final Map<String, dynamic>? name;
  final String? slug;
  final String? sku;
  final Map<String, dynamic>? shortDescription;
  final Map<String, dynamic>? description;
  final double? price;
  final double? effectivePrice;
  final double? dealDiscountAmount;

  /// Discount off [price] as a percentage (e.g. `32.0`), already resolved by
  /// the backend for this product. Preferred over `activeDeal.discountValue`
  /// for a "-N%" badge: a fixed-amount deal's `discountValue` is an amount,
  /// not a percentage.
  final double? discountPercentage;
  final double? comparePrice;
  final int? stock;
  final bool? inStock;
  final String? status;
  final bool? isFeatured;
  final String? publishedAt;
  final String? metaTitle;
  final String? metaDescription;
  final String? searchKeywords;
  // final String? primaryImage;
  final List<String>? images;
  final bool? hasVariants;
  final StoreModel? vendor;
  final String? createdAt;
  final String? updatedAt;
  // final String? imageUrl;
  final ActiveDealModel? activeDeal;
  final int? quantity;
  final bool? isSelected;
  final int? cartQuantity;
  final bool? isFavorite;
  final CategoryModel? subCategory;
  final RatingModel? rating;

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
    this.discountPercentage,
    this.comparePrice,
    this.stock,
    this.inStock,
    this.status,
    this.isFeatured,
    this.publishedAt,
    this.metaTitle,
    this.metaDescription,
    this.searchKeywords,
    // this.primaryImage,
    this.images,
    this.hasVariants,
    this.vendor,
    this.createdAt,
    this.updatedAt,
    this.activeDeal,
    this.quantity,
    this.isSelected,
    // this.imageUrl,
    this.cartQuantity,
    this.isFavorite,
    this.subCategory,
    this.rating,
  });

  /// Returns a copy with the given fields replaced. Used for in-place list
  /// edits (e.g. flipping [isFavorite] on the single product whose favourite
  /// status changed, without refetching the list).
  ProductModel copyWith({
    int? id,
    int? productId,
    int? categoryId,
    Map<String, dynamic>? name,
    String? slug,
    String? sku,
    Map<String, dynamic>? shortDescription,
    Map<String, dynamic>? description,
    double? price,
    double? effectivePrice,
    double? dealDiscountAmount,
    double? discountPercentage,
    double? comparePrice,
    int? stock,
    bool? inStock,
    String? status,
    bool? isFeatured,
    String? publishedAt,
    String? metaTitle,
    String? metaDescription,
    String? searchKeywords,
    List<String>? images,
    bool? hasVariants,
    StoreModel? vendor,
    String? createdAt,
    String? updatedAt,
    ActiveDealModel? activeDeal,
    int? quantity,
    bool? isSelected,
    int? cartQuantity,
    bool? isFavorite,
    CategoryModel? subCategory,
    RatingModel? rating,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      sku: sku ?? this.sku,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      price: price ?? this.price,
      effectivePrice: effectivePrice ?? this.effectivePrice,
      dealDiscountAmount: dealDiscountAmount ?? this.dealDiscountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      comparePrice: comparePrice ?? this.comparePrice,
      stock: stock ?? this.stock,
      inStock: inStock ?? this.inStock,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      publishedAt: publishedAt ?? this.publishedAt,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      images: images ?? this.images,
      hasVariants: hasVariants ?? this.hasVariants,
      vendor: vendor ?? this.vendor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeDeal: activeDeal ?? this.activeDeal,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      cartQuantity: cartQuantity ?? this.cartQuantity,
      isFavorite: isFavorite ?? this.isFavorite,
      subCategory: subCategory ?? this.subCategory,
      rating: rating ?? this.rating,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      categoryId: json['category_id'] as int?,
      name: json.localized('name'),
      description: json.localized('description'),
      slug: json['slug'] as String?,
      sku: json['sku'] as String?,
      activeDeal: json['active_deal'] == null
          ? null
          : ActiveDealModel.fromJson(json['active_deal']),
      // shortDescription: json['short_description'],
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      effectivePrice: (json['effective_price'] as num?)?.toDouble(),
      dealDiscountAmount: (json['deal_discount_amount'] as num?)?.toDouble(),
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      comparePrice:
          double.tryParse(json['compare_price']?.toString() ?? '') ?? 0.0,
      stock: (json['stock'] as num?)?.toInt(),
      inStock: json['in_stock'] as bool?,
      status: json['status'] as String?,
      isFeatured: json['is_featured'] as bool?,
      publishedAt: json['published_at'] as String?,
      // metaTitle: json['meta_title'] as String?,
      // metaDescription: json['meta_description'] as String?,
      searchKeywords: json['search_keywords'] as String?,
      // imageUrl: json['image_url'] as String?,
      images: _imagesFrom(json),
      hasVariants: json['has_variants'] as bool?,
      /*      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category']),*/
      vendor: _vendorFrom(json),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      isSelected: json['is_selected'] as bool?,
      cartQuantity: (json['cart_quantity'] as num?)?.toInt(),
      // Both spellings are in use across endpoints — the `/home-sections`
      // feed's product items send the British `is_favourite`.
      isFavorite: (json['is_favorite'] ?? json['is_favourite']) as bool?,
      subCategory: CategoryModel.fromJson(json['sub_category'] as Map<String, dynamic>?),
      rating: RatingModel.fromJson(json['rating'] as Map<String, dynamic>?),
    );
  }

  /// The store this product belongs to. Most endpoints nest the whole `vendor`
  /// object; the `/home-sections` feed sends only `vendor_logo_url`, which is
  /// all a product card renders — carried through as a logo-only store so the
  /// card reads it from the same place either way.
  static StoreModel? _vendorFrom(Map<String, dynamic> json) {
    final Object? vendor = json['vendor'];
    if (vendor is Map<String, dynamic>) return StoreModel.fromJson(vendor);

    final String? logoUrl = json['vendor_logo_url']?.toString();
    return logoUrl == null || logoUrl.isEmpty
        ? null
        : StoreModel(logoUrl: logoUrl);
  }

  /// Image URLs for the product. Prefers the `images` gallery (sent by the
  /// product-details endpoint), then the single `primary_image` object (most
  /// list endpoints send only that), then a bare `image_url` string (the
  /// `/home-sections` feed's flattened product items) — so list cards always
  /// have an image whichever shape the endpoint chose.
  static List<String> _imagesFrom(Map<String, dynamic> json) {
    // A gallery entry is an attachment object (`download_url`) on most
    // endpoints, but the feed sends bare URL strings — subscripting one of
    // those threw and took the whole parse down with it.
    final List<String> gallery = (json['images'] as List<dynamic>?)
            ?.map((e) => e is Map<String, dynamic> ? e['download_url'] : e)
            .whereType<String>()
            .toList() ??
        <String>[];
    if (gallery.isNotEmpty) return gallery;

    final String? primary =
        (json['primary_image'] as Map<String, dynamic>?)?['download_url']
            as String?;
    if (primary != null) return <String>[primary];

    final String? flat = json['image_url']?.toString();
    return flat == null || flat.isEmpty ? <String>[] : <String>[flat];
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
      'discount_percentage': discountPercentage,
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
      // 'primary_image': primaryImage,
      // 'image_url': imageUrl,
      'images': images,
      'has_variants': hasVariants,
      // 'category': category?.toJson(),
      'vendor': vendor?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'quantity': quantity,
      'is_selected': isSelected,
      'cart_quantity': cartQuantity,
      'is_favorite': isFavorite,
      'sub_category': subCategory?.toJson(),
      'rating': rating?.toJson(),
    };
  }
}
