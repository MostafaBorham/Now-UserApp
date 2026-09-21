import 'dart:ui';

import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/offer_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';

class StoreModel {
  final int? id;



  final Map<String, dynamic>? name;



  final Map<String, dynamic>? description;
  final String? logoUrl;
  final String? coverUrl;
  final bool? isOpen;
  final bool? acceptingOrders;
  final double? minOrderValue;
  final double? rating;
  final int? ratingCount;
  final double? deliveryFee;
  final String? deliveryTime;
  final double? distance;
  final List<CategoryModel>? categories;
  final List<CouponModel>? coupons;
  final List<ProductModel>? products;
  final OfferModel? offer;
  final List<BannerModel>? banners;
  final bool? isFavorite;





  final Color? storeColor;

  const StoreModel({
    this.id,
    this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.isOpen,
    this.acceptingOrders,
    this.minOrderValue,
    this.rating,
    this.ratingCount,
    this.deliveryFee,
    this.deliveryTime,
    this.distance,
    this.categories,
    this.coupons,
    this.products,
    this.offer,
    this.banners,
    this.isFavorite,
    this.storeColor,
  });










  static Map<String, dynamic>? _translations(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) return <String, dynamic>{'en': raw, 'ar': raw};
    return null;
  }

  factory StoreModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StoreModel();
    }

    return StoreModel(
      id: (json['id'] as num?)?.toInt(),
      name: _translations(json['name']),
      description: _translations(json['description']),
      logoUrl: json['logo_url']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      isOpen: json['is_open'] as bool?,
      acceptingOrders: json['accepting_orders'] as bool?,
      minOrderValue: (json['min_order_value'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      deliveryTime: json['delivery_time']?.toString(),
      distance: (json['distance'] as num?)?.toDouble(),
      categories: (json['categories'] as List?)
          ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>?))
          .toList(),
      coupons: (json['coupons'] as List?)
          ?.map((e) => CouponModel.fromJson(e as Map<String, dynamic>?))
          .toList(),
      products: (json['products'] as List?)
          ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      // The storefront now returns a single leading offer (or null), not a
      // list — the store screen only ever led with the first one anyway.
      offer: json['offer'] == null
          ? null
          : OfferModel.fromJson(json['offer'] as Map<String, dynamic>?),
      banners: (json['banners'] as List?)
          ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>?))
          .toList(),



      isFavorite: (json['is_favorite'] ?? json['is_favourite']) as bool?,
      storeColor: json.colorHex('store_color'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'is_open': isOpen,
      'accepting_orders': acceptingOrders,
      'min_order_value': minOrderValue,
      'rating': rating,
      'rating_count': ratingCount,
      'delivery_fee': deliveryFee,
      'delivery_time': deliveryTime,
      'distance': distance,
      'categories': categories?.map((e) => e.toJson()).toList(),
      'coupons': coupons?.map((e) => e.toJson()).toList(),
      'products': products?.map((e) => e.toJson()).toList(),
      'offer': offer?.toJson(),
      'banners': banners?.map((e) => e.toJson()).toList(),
      'is_favorite': isFavorite,

      'store_color': storeColor?.toARGB32().toRadixString(16),
    };
  }

  StoreModel copyWith({
    int? id,
    Map<String, dynamic>? name,
    Map<String, dynamic>? description,
    String? logoUrl,
    String? coverUrl,
    bool? isOpen,
    bool? acceptingOrders,
    double? minOrderValue,
    double? rating,
    int? ratingCount,
    double? deliveryFee,
    String? deliveryTime,
    double? distance,
    List<CategoryModel>? categories,
    List<CouponModel>? coupons,
    List<ProductModel>? products,
    OfferModel? offer,
    List<BannerModel>? banners,
    bool? isFavorite,
    Color? storeColor,
  }) {
    return StoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isOpen: isOpen ?? this.isOpen,
      acceptingOrders: acceptingOrders ?? this.acceptingOrders,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      distance: distance ?? this.distance,
      categories: categories ?? this.categories,
      coupons: coupons ?? this.coupons,
      products: products ?? this.products,
      offer: offer ?? this.offer,
      banners: banners ?? this.banners,
      isFavorite: isFavorite ?? this.isFavorite,
      storeColor: storeColor ?? this.storeColor,
    );
  }
}
