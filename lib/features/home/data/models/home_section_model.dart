import 'package:equatable/equatable.dart';

/// One section of the `/api/v1/home-sections` feed, in display order.
///
/// Only two types are wired today: `featured_offers` carries its tappable
/// [offers]; `categories` is a presence-only marker (its carousel content still
/// comes from `getAppCategoriesProvider`, because feed category items lack the
/// `slug` the category-details screen navigates by). Every other type is kept
/// as a bare [type] and rendered by nothing yet.
class HomeSectionModel extends Equatable {
  final int? id;
  final String type;

  /// Already localized to the requested `lang` (the feed resolves it server-side).
  final String? title;
  final List<HomeOfferModel> offers;

  const HomeSectionModel({
    this.id,
    required this.type,
    this.title,
    this.offers = const <HomeOfferModel>[],
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    final String type = json['type']?.toString() ?? '';
    final List<dynamic> rawItems =
        json['items'] as List<dynamic>? ?? <dynamic>[];

    return HomeSectionModel(
      id: (json['id'] as num?)?.toInt(),
      type: type,
      title: json['title']?.toString(),
      offers: type == 'featured_offers'
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(HomeOfferModel.fromJson)
              .toList()
          : const <HomeOfferModel>[],
    );
  }

  @override
  List<Object?> get props => <Object?>[id, type, title, offers];
}

/// A single tappable offer inside a `featured_offers` section. [kind] routes the
/// tap: `store` → store details by [storeId]; `product` → product details by
/// [productSlug].
class HomeOfferModel extends Equatable {
  final String? title;
  final String? imageUrl;
  final String? kind;
  final int? storeId;
  final String? productSlug;

  const HomeOfferModel({
    this.title,
    this.imageUrl,
    this.kind,
    this.storeId,
    this.productSlug,
  });

  factory HomeOfferModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> link =
        json['link'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final dynamic product = link['product'];

    return HomeOfferModel(
      title: json['title']?.toString(),
      imageUrl: json['image_url']?.toString(),
      kind: link['kind']?.toString(),
      storeId: (link['store'] as num?)?.toInt(),
      // The backend currently sends a numeric product *id* here, which product
      // details (slug-only) can't open — so a numeric value stays null and the
      // tap is inert. It will emit a real slug in `product_slug` (or a string
      // `product`); read that and product taps start working with no app change.
      productSlug: link['product_slug']?.toString() ??
          (product is String ? product : null),
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[title, imageUrl, kind, storeId, productSlug];
}
