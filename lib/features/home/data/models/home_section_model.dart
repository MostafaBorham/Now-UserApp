import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';















class HomeSectionModel extends Equatable {
  final int? id;
  final String type;





  final Map<String, dynamic>? title;
  final List<HomeOfferModel> offers;




  final List<StoreModel> stores;




  final List<ProductModel> products;




  final List<BannerModel> banners;




  final CategoryModel? category;




  final Color? primaryColor;


  final Color? textColor;




  final Color? backgroundColor;



  final Color? viewAllTextColor;
  final Color? viewAllUnderlineColor;



  final String? displayDesign;




  final Map<String, dynamic>? media;


  final bool showViewAll;


  static const Set<String> _storeTypes = <String>{
    'featured_stores',
    'nearby_stores',
    'all_stores',
  };



  static const Set<String> _bannerTypes = <String>{
    'promo_block_middle',
    'promo_block_footer',
  };

  const HomeSectionModel({
    this.id,
    required this.type,
    this.title,
    this.offers = const <HomeOfferModel>[],
    this.stores = const <StoreModel>[],
    this.products = const <ProductModel>[],
    this.banners = const <BannerModel>[],
    this.category,
    this.primaryColor,
    this.textColor,
    this.backgroundColor,
    this.viewAllTextColor,
    this.viewAllUnderlineColor,
    this.displayDesign,
    this.media,
    this.showViewAll = false,
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final String type = json['type']?.toString() ?? '';
    final List<dynamic> rawItems =
        json['items'] as List<dynamic>? ?? <dynamic>[];
    final bool isProductsByCategory = type == 'products_by_category';

    return HomeSectionModel(
      id: (json['id'] as num?)?.toInt(),
      type: type,
      title: json.localized('title'),
      offers: type == 'featured_offers'
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(HomeOfferModel.fromJson)
              .toList()
          : const <HomeOfferModel>[],




      stores: _storeTypes.contains(type)
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(StoreModel.fromJson)
              .toList()
          : const <StoreModel>[],
      products: type == 'flash_offers'
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .expand(
                (Map<String, dynamic> offer) =>
                    (offer['products'] as List<dynamic>? ?? <dynamic>[])
                        .whereType<Map<String, dynamic>>(),
              )
              .map(ProductModel.fromJson)
              .toList()


          : isProductsByCategory
              ? rawItems
                  .whereType<Map<String, dynamic>>()
                  .map(ProductModel.fromJson)
                  .toList()
              : const <ProductModel>[],
      banners: _bannerTypes.contains(type)
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(BannerModel.fromJson)
              .toList()
          : const <BannerModel>[],



      category: isProductsByCategory
          ? CategoryModel(
              id: (json['category_id'] as num?)?.toInt(),
              name: json.localized('category_name') ?? json.localized('title'),
            )
          : null,
      primaryColor: json.colorHex('primary_color'),
      textColor: json.colorHex('text_color'),
      backgroundColor: json.colorHex('background_color'),
      viewAllTextColor: json.colorHex('view_all_text_color'),
      viewAllUnderlineColor: json.colorHex('view_all_underline_color'),
      displayDesign: json['display_design']?.toString(),
      media: _mediaFrom(json),
      showViewAll: json['show_view_all'] == true,
    );
  }



  static Map<String, dynamic>? _mediaFrom(Map<String, dynamic> json) {
    final Object? fallback = json['media'];
    final Object? ar = json['media_ar'] ?? fallback;
    final Object? en = json['media_en'] ?? fallback;
    return ar == null && en == null
        ? null
        : <String, dynamic>{'ar': ar, 'en': en};
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        type,
        title,
        offers,
        stores,
        products,
        banners,
        category,
        primaryColor,
        textColor,
        backgroundColor,
        viewAllTextColor,
        viewAllUnderlineColor,
        displayDesign,
        media,
        showViewAll,
      ];
}




class HomeOfferModel extends Equatable {
  final String? title;
  final String? imageUrl;
  final String? kind;
  final int? storeId;
  final String? productSlug;
  final String? categorySlug;

  const HomeOfferModel({
    this.title,
    this.imageUrl,
    this.kind,
    this.storeId,
    this.productSlug,
    this.categorySlug,
  });

  factory HomeOfferModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> link =
        json['link'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final dynamic product = link['product'];
    final dynamic category = link['category'];

    return HomeOfferModel(
      title: json['title']?.toString(),
      imageUrl: json['image_url']?.toString(),
      kind: link['kind']?.toString(),
      storeId: (link['store'] as num?)?.toInt(),




      productSlug: link['product_slug']?.toString() ??
          (product is String ? product : null),
      categorySlug: link['category_slug']?.toString() ??
          (category is String ? category : null),
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[title, imageUrl, kind, storeId, productSlug, categorySlug];
}
