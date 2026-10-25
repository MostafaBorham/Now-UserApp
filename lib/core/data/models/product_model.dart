import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';
import 'package:nowdelivery_user_app/core/data/models/active_deal_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_attribute_model.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_color_model.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_specification_model.dart';
import 'package:nowdelivery_user_app/features/products/data/models/rating_model.dart';

class ProductModel {
  final int? id;
  final int? productId;
  final int? categoryId;
  final int? vendorId;
  final Map<String, dynamic>? name;
  final String? slug;
  final String? sku;
  final Map<String, dynamic>? shortDescription;
  final Map<String, dynamic>? description;





  final List<Map<String, dynamic>>? mainFeatures;
  final double? price;
  final double? discountPrice;
  final double? effectivePrice;
  final double? dealDiscountAmount;





  final double? discountPercentage;
  final double? comparePrice;
  final int? stock;



  final int? minOrderQuantity;


  final String? unit;
  final bool? inStock;


  final bool? inCart;
  final String? status;
  final bool? isFeatured;
  final String? publishedAt;
  final String? metaTitle;
  final String? metaDescription;
  final String? searchKeywords;

  final List<String>? images;
  final bool? hasVariants;




  final List<dynamic>? variants;


  final List<ProductSpecificationModel>? specifications;


  final List<ProductAttributeModel>? attributes;


  final List<ProductColorModel>? colors;
  final StoreModel? vendor;
  final String? createdAt;
  final String? updatedAt;

  final ActiveDealModel? activeDeal;
  final int? quantity;

  /// On an order line: how many of [quantity] came back after delivery
  /// (`returned_quantity`). `null` off orders.
  final int? returnedQuantity;
  final bool? isSelected;
  final int? cartQuantity;
  final bool? isFavorite;

  /// The cart line's row id (`cart_item_id`). One product can be in the cart as
  /// several lines — one per selected color/attributes combination — so this,
  /// not `productId`, is what identifies a single line. `null` off the cart.
  final int? cartItemId;

  /// The selected variant of a cart line, as the server sends it: a raw
  /// `{color, attributes}` map. Kept untyped like [variants] so this core model
  /// stays free of cart-feature types; the cart reads it for the variant pills.
  final Map<String, dynamic>? options;


  final CategoryModel? category;



  final CategoryModel? subCategory;
  final RatingModel? rating;

  const ProductModel({
    this.id,
    this.productId,
    this.categoryId,
    this.vendorId,
    this.name,
    this.slug,
    this.sku,
    this.shortDescription,
    this.description,
    this.mainFeatures,
    this.price,
    this.discountPrice,
    this.effectivePrice,
    this.dealDiscountAmount,
    this.discountPercentage,
    this.comparePrice,
    this.stock,
    this.minOrderQuantity,
    this.unit,
    this.inStock,
    this.inCart,
    this.status,
    this.isFeatured,
    this.publishedAt,
    this.metaTitle,
    this.metaDescription,
    this.searchKeywords,

    this.images,
    this.hasVariants,
    this.variants,
    this.specifications,
    this.attributes,
    this.colors,
    this.vendor,
    this.createdAt,
    this.updatedAt,
    this.activeDeal,
    this.quantity,
    this.returnedQuantity,
    this.isSelected,

    this.cartQuantity,
    this.isFavorite,
    this.cartItemId,
    this.options,
    this.category,
    this.subCategory,
    this.rating,
  });

  /// True only when [discountPrice] is a genuine markdown below [price]. The
  /// API sends `discountPrice == price` when there is no active deal, so a plain
  /// null-check would strike a "was" price on every product. Callers show the
  /// struck-through original price only when this is true.
  bool get hasDeal =>
      price != null && discountPrice != null && discountPrice! < price!;

  ProductModel copyWith({
    int? id,
    int? productId,
    int? categoryId,
    int? vendorId,
    Map<String, dynamic>? name,
    String? slug,
    String? sku,
    Map<String, dynamic>? shortDescription,
    Map<String, dynamic>? description,
    List<Map<String, dynamic>>? mainFeatures,
    double? price,
    double? discountPrice,
    double? effectivePrice,
    double? dealDiscountAmount,
    double? discountPercentage,
    double? comparePrice,
    int? stock,
    int? minOrderQuantity,
    String? unit,
    bool? inStock,
    bool? inCart,
    String? status,
    bool? isFeatured,
    String? publishedAt,
    String? metaTitle,
    String? metaDescription,
    String? searchKeywords,
    List<String>? images,
    bool? hasVariants,
    List<dynamic>? variants,
    List<ProductSpecificationModel>? specifications,
    List<ProductAttributeModel>? attributes,
    List<ProductColorModel>? colors,
    StoreModel? vendor,
    String? createdAt,
    String? updatedAt,
    ActiveDealModel? activeDeal,
    int? quantity,
    int? returnedQuantity,
    bool? isSelected,
    int? cartQuantity,
    bool? isFavorite,
    int? cartItemId,
    Map<String, dynamic>? options,
    CategoryModel? category,
    CategoryModel? subCategory,
    RatingModel? rating,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      sku: sku ?? this.sku,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      mainFeatures: mainFeatures ?? this.mainFeatures,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      effectivePrice: effectivePrice ?? this.effectivePrice,
      dealDiscountAmount: dealDiscountAmount ?? this.dealDiscountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      comparePrice: comparePrice ?? this.comparePrice,
      stock: stock ?? this.stock,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      unit: unit ?? this.unit,
      inStock: inStock ?? this.inStock,
      inCart: inCart ?? this.inCart,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      publishedAt: publishedAt ?? this.publishedAt,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      images: images ?? this.images,
      hasVariants: hasVariants ?? this.hasVariants,
      variants: variants ?? this.variants,
      specifications: specifications ?? this.specifications,
      attributes: attributes ?? this.attributes,
      colors: colors ?? this.colors,
      vendor: vendor ?? this.vendor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeDeal: activeDeal ?? this.activeDeal,
      quantity: quantity ?? this.quantity,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      isSelected: isSelected ?? this.isSelected,
      cartQuantity: cartQuantity ?? this.cartQuantity,
      isFavorite: isFavorite ?? this.isFavorite,
      cartItemId: cartItemId ?? this.cartItemId,
      options: options ?? this.options,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      rating: rating ?? this.rating,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      categoryId: json['category_id'] as int?,
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      name: json.localized('name'),
      description: json.localized('description'),
      mainFeatures: _mainFeaturesFrom(json),
      slug: json['slug'] as String?,
      sku: json['sku'] as String?,
      activeDeal: json['active_deal'] == null
          ? null
          : ActiveDealModel.fromJson(json['active_deal']),

      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      // Backend key is camelCase `discountPrice` (deal-adjusted unit price,
      // always present, equals `price` when there is no deal). The detail
      // endpoint drops `effective_price`; the list endpoint still sends it as a
      // duplicate, kept here as a fallback.
      discountPrice: (json['discountPrice'] as num?)?.toDouble() ??
          (json['effective_price'] as num?)?.toDouble(),
      effectivePrice: (json['effective_price'] as num?)?.toDouble(),
      dealDiscountAmount: (json['deal_discount_amount'] as num?)?.toDouble(),
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      comparePrice: (json['compare_price'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt(),
      minOrderQuantity: (json['min_order_quantity'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      inStock: json['in_stock'] as bool?,
      inCart: json['in_cart'] as bool?,
      status: json['status'] as String?,
      isFeatured: json['is_featured'] as bool?,
      publishedAt: json['published_at'] as String?,


      searchKeywords: json['search_keywords'] as String?,

      images: _imagesFrom(json),
      hasVariants: json['has_variants'] as bool?,
      variants: json['variants'] as List<dynamic>?,
      specifications: (json['specifications_translations'] as List<dynamic>?)
          ?.map(
            (e) => ProductSpecificationModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map(
            (e) => ProductAttributeModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => ProductColorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>?),
      vendor: _vendorFrom(json),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      returnedQuantity: (json['returned_quantity'] as num?)?.toInt(),
      isSelected: json['is_selected'] as bool?,
      cartQuantity: (json['cart_quantity'] as num?)?.toInt(),
      cartItemId: (json['cart_item_id'] as num?)?.toInt(),
      options: json['options'] as Map<String, dynamic>?,


      isFavorite: (json['is_favorite'] ?? json['is_favourite']) as bool?,
      subCategory: CategoryModel.fromJson(json['sub_category'] as Map<String, dynamic>?),
      rating: RatingModel.fromJson(json['rating'] as Map<String, dynamic>?),
    );
  }





  static StoreModel? _vendorFrom(Map<String, dynamic> json) {
    final Object? vendor = json['vendor'];
    if (vendor is Map<String, dynamic>) return StoreModel.fromJson(vendor);

    final String? logoUrl = json['vendor_logo_url']?.toString();
    return logoUrl == null || logoUrl.isEmpty
        ? null
        : StoreModel(logoUrl: logoUrl);
  }






  static List<Map<String, dynamic>>? _mainFeaturesFrom(
    Map<String, dynamic> json,
  ) {
    final dynamic raw = json['main_features'];
    if (raw == null) return null;
    final List<dynamic> items = raw is List ? raw : <dynamic>[raw];
    final List<Map<String, dynamic>> features = <Map<String, dynamic>>[];
    for (final dynamic item in items) {
      if (item is Map<String, dynamic>) {
        features.add(item);
      } else if (item is String) {
        features.add(<String, dynamic>{'ar': item, 'en': item});
      }
    }
    return features.isEmpty ? null : features;
  }






  static List<String> _imagesFrom(Map<String, dynamic> json) {



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
      'vendor_id': vendorId,
      'name': name,
      'slug': slug,
      'sku': sku,
      'short_description': shortDescription,
      'description': description,
      'main_features': mainFeatures,
      'price': price,
      'discount_price': discountPrice,
      'effective_price': effectivePrice,
      'deal_discount_amount': dealDiscountAmount,
      'discount_percentage': discountPercentage,
      'compare_price': comparePrice,
      'stock': stock,
      'min_order_quantity': minOrderQuantity,
      'unit': unit,
      'in_stock': inStock,
      'in_cart': inCart,
      'status': status,
      'is_featured': isFeatured,
      'published_at': publishedAt,
      'active_deal': activeDeal?.toJson(),
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'search_keywords': searchKeywords,


      'images': images,
      'has_variants': hasVariants,
      'variants': variants,
      'specifications_translations':
          specifications?.map((e) => e.toJson()).toList(),
      'attributes': attributes?.map((e) => e.toJson()).toList(),
      'colors': colors?.map((e) => e.toJson()).toList(),
      'category': category?.toJson(),
      'vendor': vendor?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'quantity': quantity,
      'returned_quantity': returnedQuantity,
      'is_selected': isSelected,
      'cart_quantity': cartQuantity,
      'is_favorite': isFavorite,
      'cart_item_id': cartItemId,
      'options': options,
      'sub_category': subCategory?.toJson(),
      'rating': rating?.toJson(),
    };
  }
}
