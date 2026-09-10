import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';

/// One section of the `/api/v1/home-sections` feed, in display order.
///
/// Seven types are wired today: `featured_offers` carries its tappable
/// [offers]; `featured_stores`, `nearby_stores` and `all_stores` all carry
/// their [stores] (a featured store also brings the products its card shows);
/// `flash_offers` and `products_by_category` carry their [products] (the
/// latter also brings the [category] it lists plus its own [primaryColor] /
/// [textColor] / [displayDesign] theming); `promo_block_middle` and
/// `promo_block_footer` carry their [banners]; `categories` is a presence-only
/// marker (its carousel content still comes from `getAppCategoriesProvider`,
/// because feed category items lack the `slug` the category-details screen
/// navigates by). Every other type is kept as a bare [type] and rendered by
/// nothing yet.
class HomeSectionModel extends Equatable {
  final int? id;
  final String type;

  /// Section heading as a `{ar, en}` translation map. The feed used to resolve
  /// it server-side from the `lang` query param and send a plain string; it now
  /// sends both locales (sometimes only `ar`) and leaves the choice to the
  /// client. Resolve it for display with `context.getLocalizedApiText(title)`.
  final Map<String, dynamic>? title;
  final List<HomeOfferModel> offers;

  /// Stores of a `featured_stores`, `nearby_stores` or `all_stores` section. A
  /// featured store's `products` are the tiles its card renders; a nearby or
  /// all-stores item has none — its card shows the store's own details instead.
  final List<StoreModel> stores;

  /// Products of a `flash_offers` section. The feed groups them under
  /// `home_page_offer` wrappers, but the section renders one card per product,
  /// so every wrapper's products are flattened into this single list.
  final List<ProductModel> products;

  /// Banner items of a `promo_block_middle` / `promo_block_footer` section.
  /// Their `image_ar` / `image_en` arrive as bare URL strings, which
  /// [BannerModel] reads as-is.
  final List<BannerModel> banners;

  /// The category a `products_by_category` section lists, titled by
  /// `category_name` (falling back to the section's own `title`). It carries no
  /// `slug`, so it cannot open category details — see [showViewAll].
  final CategoryModel? category;

  /// Accent colour of a `products_by_category` section: the background wash and
  /// the "See All" chip. Null when the admin left it unset or sent a malformed
  /// hex — the section then falls back to a theme colour.
  final Color? primaryColor;

  /// Colour of a `products_by_category` section's title.
  final Color? textColor;

  /// Header design of a `products_by_category` section: `color_with_image`
  /// shows [media] beside the title, anything else is colour-only.
  final String? displayDesign;

  /// Header artwork of a `color_with_image` section, as a `{ar, en}` map
  /// (`media_ar` / `media_en`, each falling back to the plain `media`) so the
  /// right locale's image is picked at render time.
  final Map<String, dynamic>? media;

  /// Whether the section's header shows a "See All" chip.
  final bool showViewAll;

  /// Section types whose `items` are vendors, parsed into [stores].
  static const Set<String> _storeTypes = <String>{
    'featured_stores',
    'nearby_stores',
    'all_stores',
  };

  /// Section types whose `items` are banner slots, parsed into [banners]. Both
  /// send the same item shape, differing only in their `slot`.
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
      // Vendor items use the same keys as every other store payload, so
      // StoreModel parses them as-is — nested `products` included. Sections
      // still sending the thin vendor item (id/name/image_url only) parse too;
      // the fields they omit stay null and their card leaves those rows out.
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
          // A products_by_category item is the product itself — no offer
          // wrapper to flatten, unlike flash_offers above.
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
      // `title` is the admin's own label for the section ("products by
      // category"), identical on every section of this type, so the heading
      // shown is the category's name; the title is only a last resort.
      category: isProductsByCategory
          ? CategoryModel(
              id: (json['category_id'] as num?)?.toInt(),
              name: json.localized('category_name') ?? json.localized('title'),
            )
          : null,
      primaryColor: json.colorHex('primary_color'),
      textColor: json.colorHex('text_color'),
      displayDesign: json['display_design']?.toString(),
      media: _mediaFrom(json),
      showViewAll: json['show_view_all'] == true,
    );
  }

  /// The section's header artwork per locale. `media_ar` / `media_en` each fall
  /// back to the plain `media`; null when the section carries no artwork at all.
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
        displayDesign,
        media,
        showViewAll,
      ];
}

/// A single tappable offer inside a `featured_offers` section. [kind] routes the
/// tap: `store` → store details by [storeId]; `product` → product details by
/// [productSlug]; `category` → category details by [categorySlug].
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
      // `product` / `category` now carry the target's slug, which is what both
      // details screens navigate by. Older responses put a numeric *id* there;
      // one of those stays null, leaving the tap inert rather than opening the
      // wrong screen.
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
