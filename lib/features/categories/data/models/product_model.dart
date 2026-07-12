import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';

class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String sku;
  final String shortDescription;
  final String description;
  final double price;
  final double effectivePrice;
  final double dealDiscountAmount;
  final double comparePrice;
  final int stock;
  final bool inStock;
  final String status;
  final bool isFeatured;
  final String? publishedAt;
  final String metaTitle;
  final String metaDescription;
  final String searchKeywords;
  final String? primaryImage;
  final List<String> images;
  final bool hasVariants;
  final CategoryModel category;
  final StoreModel vendor;
  final String createdAt;
  final String updatedAt;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.sku,
    required this.shortDescription,
    required this.description,
    required this.price,
    required this.effectivePrice,
    required this.dealDiscountAmount,
    required this.comparePrice,
    required this.stock,
    required this.inStock,
    required this.status,
    required this.isFeatured,
    this.publishedAt,
    required this.metaTitle,
    required this.metaDescription,
    required this.searchKeywords,
    this.primaryImage,
    required this.images,
    required this.hasVariants,
    required this.category,
    required this.vendor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      slug: json['slug'],
      sku: json['sku'],
      shortDescription: json['short_description'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      effectivePrice: (json['effective_price'] as num).toDouble(),
      dealDiscountAmount: (json['deal_discount_amount'] as num).toDouble(),
      comparePrice: (json['compare_price'] as num).toDouble(),
      stock: json['stock'],
      inStock: json['in_stock'],
      status: json['status'],
      isFeatured: json['is_featured'],
      publishedAt: json['published_at'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      searchKeywords: json['search_keywords'],
      primaryImage: json['primary_image'],
      images: List<String>.from(json['images'] ?? []),
      hasVariants: json['has_variants'],
      category: CategoryModel.fromJson(json['category']),
      vendor: StoreModel.fromJson(json['vendor']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'sku': sku,
      'short_description': shortDescription,
      'description': description,
      'price': price,
      'effective_price': effectivePrice,
      'deal_discount_amount': dealDiscountAmount,
      'compare_price': comparePrice,
      'stock': stock,
      'in_stock': inStock,
      'status': status,
      'is_featured': isFeatured,
      'published_at': publishedAt,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'search_keywords': searchKeywords,
      'primary_image': primaryImage,
      'images': images,
      'has_variants': hasVariants,
      'category': category.toJson(),
      'vendor': vendor.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}