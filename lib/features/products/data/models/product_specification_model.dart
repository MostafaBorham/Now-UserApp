/// A single free-text specification row of a product as sent by the API under
/// the `specifications` list, e.g.
/// ```json
/// { "key": "Processor", "value": "Snapdragon 8 Gen 3" }
/// ```
///
/// Neither side is a localization map — the backend stores whatever text the
/// vendor typed, so both are plain strings.
class ProductSpecificationModel {
  final String? key;
  final String? value;

  const ProductSpecificationModel({this.key, this.value});

  factory ProductSpecificationModel.fromJson(Map<String, dynamic> json) {
    return ProductSpecificationModel(
      key: json['key']?.toString(),
      value: json['value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  ProductSpecificationModel copyWith({String? key, String? value}) {
    return ProductSpecificationModel(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}
