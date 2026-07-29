import 'package:equatable/equatable.dart';

/// A single category node from `GET /api/v1/categories/tree`.
///
/// The endpoint returns a nested tree, so [children] holds the same type.
class CategoryModel extends Equatable {
  final int? id;
  final Map<String, dynamic>? name;
  final String? description;
  final String? slug;
  final int? parentId;
  final int? depth;
  final String? path;
  final String? metaTitle;
  final String? metaDescription;
  final String? searchKeywords;
  final int? index;
  final bool? active;
  final String? adminStatus;
  final String? reviewedAt;
  final String? rejectionReason;
  final int? childrenCount;
  final int? descendantsCount;
  final int? productsCount;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const CategoryModel({
    this.id,
    this.name,
    this.description,
    this.slug,
    this.parentId,
    this.depth,
    this.path,
    this.metaTitle,
    this.metaDescription,
    this.searchKeywords,
    this.index,
    this.active,
    this.adminStatus,
    this.reviewedAt,
    this.rejectionReason,
    this.childrenCount,
    this.descendantsCount,
    this.productsCount,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CategoryModel();
    }

    return CategoryModel(
      id: (json['id'] as num?)?.toInt(),
      name: (json['name'] is String)
          ? {'ar': json['name'] as String, 'en': json['name'] as String}
          : json['name'],
      description: json['description']?.toString(),
      slug: json['slug']?.toString(),
      parentId: (json['parent_id'] as num?)?.toInt(),
      depth: (json['depth'] as num?)?.toInt(),
      path: json['path']?.toString(),
      metaTitle: json['meta_title']?.toString(),
      metaDescription: json['meta_description']?.toString(),
      searchKeywords: json['search_keywords']?.toString(),
      index: (json['index'] as num?)?.toInt(),
      active: json['active'] as bool?,
      adminStatus: json['admin_status']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      childrenCount: (json['children_count'] as num?)?.toInt(),
      descendantsCount: (json['descendants_count'] as num?)?.toInt(),
      productsCount: (json['products_count'] as num?)?.toInt(),
      image: (json['image'] as Map<String, dynamic>?)?['download_url']
          ?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'parent_id': parentId,
      'depth': depth,
      'path': path,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'search_keywords': searchKeywords,
      'index': index,
      'active': active,
      'admin_status': adminStatus,
      'reviewed_at': reviewedAt,
      'rejection_reason': rejectionReason,
      'children_count': childrenCount,
      'descendants_count': descendantsCount??0,
      'products_count': productsCount,
      'image': image == null
          ? null
          : {
        'download_url': image,
      },
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    slug,
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
    image,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
