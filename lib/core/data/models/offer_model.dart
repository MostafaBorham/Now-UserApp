import 'package:nowdelivery_user_app/core/data/models/product_model.dart';

class OfferModel {
  final int? id;
  final String? uuid;
  final String? name;
  final String? description;
  final String? discountType;
  final double? discountValue;
  final String? scope;
  final int? priority;
  final String? startsAt;
  final String? endsAt;
  final int? productsCount;
  final List<ProductModel>? products;

  const OfferModel({
    this.id,
    this.uuid,
    this.name,
    this.description,
    this.discountType,
    this.discountValue,
    this.scope,
    this.priority,
    this.startsAt,
    this.endsAt,
    this.productsCount,
    this.products,
  });

  factory OfferModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OfferModel();
    }

    return OfferModel(
      id: (json['id'] as num?)?.toInt(),
      uuid: json['uuid']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      discountType: json['discount_type']?.toString(),
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      scope: json['scope']?.toString(),
      priority: (json['priority'] as num?)?.toInt(),
      startsAt: json['starts_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
      productsCount: (json['products_count'] as num?)?.toInt(),
      products: (json['products'] as List?)
          ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'scope': scope,
      'priority': priority,
      'starts_at': startsAt,
      'ends_at': endsAt,
      'products_count': productsCount,
      'products': products?.map((e) => e.toJson()).toList(),
    };
  }

  OfferModel copyWith({
    int? id,
    String? uuid,
    String? name,
    String? description,
    String? discountType,
    double? discountValue,
    String? scope,
    int? priority,
    String? startsAt,
    String? endsAt,
    int? productsCount,
    List<ProductModel>? products,
  }) {
    return OfferModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      scope: scope ?? this.scope,
      priority: priority ?? this.priority,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      productsCount: productsCount ?? this.productsCount,
      products: products ?? this.products,
    );
  }
}
