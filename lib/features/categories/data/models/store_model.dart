import 'package:nowdelivery_user_app/features/categories/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/coupon_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';

class StoreModel {
  final int? id;
  final String? name;
  final String? description;
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
  final List<BannerModel>? banners;

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
    this.banners,
  });

  factory StoreModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StoreModel();
    }

    return StoreModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
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
      banners: (json['banners'] as List?)
          ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>?))
          .toList(),
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
      'banners': banners?.map((e) => e.toJson()).toList(),
    };
  }

  StoreModel copyWith({
    int? id,
    String? name,
    String? description,
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
    List<BannerModel>? banners,
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
      banners: banners ?? this.banners,
    );
  }
}