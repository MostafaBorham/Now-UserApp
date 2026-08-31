import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';

class BannerModel extends Equatable {
  final int? id;

  /// Localized text fields as API translation maps (`{'en': ..., 'ar': ...}`).
  /// Resolve for display with `context.getLocalizedApiText(...)`.
  final Map<String, dynamic>? title;
  final Map<String, dynamic>? subtitle;
  final Map<String, dynamic>? description;
  final String? type;
  final String? linkType;
  final String? defaultUrl;
  final int? index;
  final bool? isFeatured;
  final int? productId;
  final int? mainCategoryId;

  /// Locale-agnostic fallback image (`image.download_url`).
  final String? image;

  /// Per-locale banner images (`image_ar.download_url` / `image_en.download_url`).
  final String? imageAr;
  final String? imageEn;
  final String? startAt;
  final String? endAt;

  const BannerModel({
    this.id,
    this.title,
    this.subtitle,
    this.description,
    this.type,
    this.linkType,
    this.defaultUrl,
    this.index,
    this.isFeatured,
    this.productId,
    this.mainCategoryId,
    this.image,
    this.imageAr,
    this.imageEn,
    this.startAt,
    this.endAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const BannerModel();
    }

    return BannerModel(
      id: (json['id'] as num?)?.toInt(),
      title: json.localized('title'),
      subtitle: json.localized('subtitle'),
      description: json.localized('description'),
      type: json['type']?.toString(),
      linkType: json['link_type']?.toString(),
      defaultUrl: json['default_url']?.toString(),
      index: (json['index'] as num?)?.toInt(),
      isFeatured: json['is_featured'] as bool?,
      productId: (json['product_id'] as num?)?.toInt(),
      mainCategoryId: (json['main_category_id'] as num?)?.toInt(),
      image: json.downloadUrl('image'),
      imageAr: json.downloadUrl('image_ar'),
      imageEn: json.downloadUrl('image_en'),
      startAt: json['start_at']?.toString(),
      endAt: json['end_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'type': type,
      'link_type': linkType,
      'default_url': defaultUrl,
      'index': index,
      'is_featured': isFeatured,
      'product_id': productId,
      'main_category_id': mainCategoryId,
      'image': image == null ? null : {'download_url': image},
      'image_ar': imageAr == null ? null : {'download_url': imageAr},
      'image_en': imageEn == null ? null : {'download_url': imageEn},
      'start_at': startAt,
      'end_at': endAt,
    };
  }

  BannerModel copyWith({
    int? id,
    Map<String, dynamic>? title,
    Map<String, dynamic>? subtitle,
    Map<String, dynamic>? description,
    String? type,
    String? linkType,
    String? defaultUrl,
    int? index,
    bool? isFeatured,
    int? productId,
    int? mainCategoryId,
    String? image,
    String? imageAr,
    String? imageEn,
    String? startAt,
    String? endAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      type: type ?? this.type,
      linkType: linkType ?? this.linkType,
      defaultUrl: defaultUrl ?? this.defaultUrl,
      index: index ?? this.index,
      isFeatured: isFeatured ?? this.isFeatured,
      productId: productId ?? this.productId,
      mainCategoryId: mainCategoryId ?? this.mainCategoryId,
      image: image ?? this.image,
      imageAr: imageAr ?? this.imageAr,
      imageEn: imageEn ?? this.imageEn,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    description,
    type,
    linkType,
    defaultUrl,
    index,
    isFeatured,
    productId,
    mainCategoryId,
    image,
    imageAr,
    imageEn,
    startAt,
    endAt,
  ];
}
