import 'package:equatable/equatable.dart';

/// A single category node from `GET /api/v1/categories/tree`.
///
/// The endpoint returns a nested tree, so [children] holds the same type.
class CategoryModel extends Equatable {
  final int id;
  final String name;
  final CategoryTranslations? translations;
  final String? description;
  final String slug;
  final int? parentId;
  final int depth;
  final String? path;
  final String? metaTitle;
  final String? metaDescription;
  final String? searchKeywords;
  final int index;
  final bool active;
  final String? adminStatus;
  final String? reviewedAt;
  final String? rejectionReason;
  final int childrenCount;
  final int descendantsCount;
  final int productsCount;
  final List<CategoryModel> children;
  final CategoryImage? image;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.translations,
    this.description,
    this.parentId,
    this.depth = 0,
    this.path,
    this.metaTitle,
    this.metaDescription,
    this.searchKeywords,
    this.index = 0,
    this.active = false,
    this.adminStatus,
    this.reviewedAt,
    this.rejectionReason,
    this.childrenCount = 0,
    this.descendantsCount = 0,
    this.productsCount = 0,
    this.children = const <CategoryModel>[],
    this.image,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Localized display name for the given [languageCode] ('ar' / 'en'),
  /// falling back to the raw [name] when no translation exists.
  String localizedName(String languageCode) {
    final LocalizedText? translatedName = translations?.name;
    final String? localized =
        languageCode == 'ar' ? translatedName?.ar : translatedName?.en;
    return (localized == null || localized.isEmpty) ? name : localized;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      translations: json['translations'] == null
          ? null
          : CategoryTranslations.fromJson(
              json['translations'] as Map<String, dynamic>,
            ),
      description: json['description'] as String?,
      parentId: (json['parent_id'] as num?)?.toInt(),
      depth: (json['depth'] as num?)?.toInt() ?? 0,
      path: json['path'] as String?,
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      searchKeywords: json['search_keywords']?.toString(),
      index: (json['index'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? false,
      adminStatus: json['admin_status'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      childrenCount: (json['children_count'] as num?)?.toInt() ?? 0,
      descendantsCount: (json['descendants_count'] as num?)?.toInt() ?? 0,
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
      children: (json['children'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic e) =>
              CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      image: json['image'] == null
          ? null
          : CategoryImage.fromJson(json['image'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        slug,
        translations,
        description,
        parentId,
        depth,
        path,
        metaTitle,
        metaDescription,
        searchKeywords,
        index,
        active,
        adminStatus,
        reviewedAt,
        rejectionReason,
        childrenCount,
        descendantsCount,
        productsCount,
        children,
        image,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}

/// `translations` object. Currently only carries the localized `name`.
class CategoryTranslations extends Equatable {
  final LocalizedText? name;

  const CategoryTranslations({this.name});

  factory CategoryTranslations.fromJson(Map<String, dynamic> json) {
    return CategoryTranslations(
      name: json['name'] == null
          ? null
          : LocalizedText.fromJson(json['name'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => <Object?>[name];
}

/// A localized value with Arabic / English variants (`{ "ar": ..., "en": ... }`).
class LocalizedText extends Equatable {
  final String? ar;
  final String? en;

  const LocalizedText({this.ar, this.en});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      ar: json['ar'] as String?,
      en: json['en'] as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[ar, en];
}

/// Image attachment nested inside a [CategoryModel] (nullable on the API).
class CategoryImage extends Equatable {
  final int? id;
  final String? originalName;
  final String? mimeType;
  final String? fileExtension;
  final int? size;
  final String? downloadUrl;
  final String? downloadPath;
  final String? createdAt;

  const CategoryImage({
    this.id,
    this.originalName,
    this.mimeType,
    this.fileExtension,
    this.size,
    this.downloadUrl,
    this.downloadPath,
    this.createdAt,
  });

  factory CategoryImage.fromJson(Map<String, dynamic> json) {
    return CategoryImage(
      id: (json['id'] as num?)?.toInt(),
      originalName: json['original_name'] as String?,
      mimeType: json['mime_type'] as String?,
      fileExtension: json['extension'] as String?,
      size: (json['size'] as num?)?.toInt(),
      downloadUrl: json['download_url'] as String?,
      downloadPath: json['download_path'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        originalName,
        mimeType,
        fileExtension,
        size,
        downloadUrl,
        downloadPath,
        createdAt,
      ];
}
