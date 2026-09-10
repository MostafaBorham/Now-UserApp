import 'dart:ui';

import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/core/data/models/offer_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';

class StoreModel {
  final int? id;

  /// Localized store name as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(name)`.
  final Map<String, dynamic>? name;

  /// Localized store description as an API translation map (`{'en': ..., 'ar': ...}`).
  /// Resolve it for display with `context.getLocalizedApiText(description)`.
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
  final List<OfferModel>? offers;
  final List<BannerModel>? banners;
  final bool? isFavorite;

  /// The store's own accent colour (`store_color`), sent by the home feed's
  /// `featured_stores` vendor items and used to tint that store's card. Null
  /// when the admin left it unset or sent a malformed hex, so the card falls
  /// back to its default tint.
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
    this.offers,
    this.banners,
    this.isFavorite,
    this.storeColor,
  });

  /// Normalizes an API translation field into a `{'en': ..., 'ar': ...}` map.
  ///
  /// The same field is not always sent as a map: a store with no description
  /// serializes it as an empty JSON array, and the thin vendor items some
  /// `/home-sections` types still send carry `name` as an already-localized
  /// plain string. Both used to be cast straight to a map, which threw and —
  /// since the throw happened while parsing the feed — took down the whole home
  /// screen, not just the one store. A string is mirrored into both locales;
  /// anything else becomes null.
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
      offers: (json['offers'] as List?)
          ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>?))
          .toList(),
      banners: (json['banners'] as List?)
          ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>?))
          .toList(),
      // Both spellings are in use across endpoints — the `/home-sections`
      // feed's vendor items send the British `is_favourite`, and reading only
      // the American one left every home store's heart unfilled.
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
      'offers': offers?.map((e) => e.toJson()).toList(),
      'banners': banners?.map((e) => e.toJson()).toList(),
      'is_favorite': isFavorite,
      // Round-trips through `colorHex`, which accepts a bare 8-digit hex.
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
    List<OfferModel>? offers,
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
      offers: offers ?? this.offers,
      banners: banners ?? this.banners,
      isFavorite: isFavorite ?? this.isFavorite,
      storeColor: storeColor ?? this.storeColor,
    );
  }
}