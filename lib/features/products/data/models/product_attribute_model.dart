/// A variant attribute of a product (e.g. Size, Material, Storage Capacity) as
/// sent by the API under the `attributes` list:
/// ```json
/// {
///   "attribute_id": "VAR-00302",
///   "name": { "ar": "المقاس", "en": "Size" },
///   "value_ids": [64, 65],
///   "values": [ { "id": 64, "slug": "medium", "ar": "متوسط", "en": "Medium" }, ... ]
/// }
/// ```
class ProductAttributeModel {
  final String? attributeId;

  /// The localized attribute label as a `{ar, en}` translation map.
  final Map<String, dynamic>? name;

  /// Ids of the values available for this attribute (mirrors [values] ids).
  final List<int>? valueIds;

  final List<ProductAttributeValueModel>? values;

  const ProductAttributeModel({
    this.attributeId,
    this.name,
    this.valueIds,
    this.values,
  });

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawName = json['name'];
    return ProductAttributeModel(
      attributeId: json['attribute_id']?.toString(),
      name: rawName is String
          ? {'ar': rawName, 'en': rawName}
          : rawName as Map<String, dynamic>?,
      valueIds: (json['value_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      values: (json['values'] as List<dynamic>?)
          ?.map(
            (e) => ProductAttributeValueModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attribute_id': attributeId,
      'name': name,
      'value_ids': valueIds,
      'values': values?.map((e) => e.toJson()).toList(),
    };
  }

  ProductAttributeModel copyWith({
    String? attributeId,
    Map<String, dynamic>? name,
    List<int>? valueIds,
    List<ProductAttributeValueModel>? values,
  }) {
    return ProductAttributeModel(
      attributeId: attributeId ?? this.attributeId,
      name: name ?? this.name,
      valueIds: valueIds ?? this.valueIds,
      values: values ?? this.values,
    );
  }
}

/// A single selectable value of a [ProductAttributeModel]. The localized label
/// arrives as sibling `ar`/`en` keys (not nested under a `name`), folded here
/// into a `{ar, en}` translation map so it reads like every other localized
/// field.
class ProductAttributeValueModel {
  final int? id;
  final String? slug;
  final Map<String, dynamic>? name;

  const ProductAttributeValueModel({this.id, this.slug, this.name});

  factory ProductAttributeValueModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeValueModel(
      id: (json['id'] as num?)?.toInt(),
      slug: json['slug']?.toString(),
      name: {'ar': json['ar'], 'en': json['en']},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'ar': name?['ar'],
      'en': name?['en'],
    };
  }

  ProductAttributeValueModel copyWith({
    int? id,
    String? slug,
    Map<String, dynamic>? name,
  }) {
    return ProductAttributeValueModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
    );
  }
}
