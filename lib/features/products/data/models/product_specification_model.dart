class ProductSpecificationModel {
  final Map<String, dynamic>? key;
  final Map<String, dynamic>? value;

  const ProductSpecificationModel({this.key, this.value});

  factory ProductSpecificationModel.fromJson(Map<String, dynamic> json) {
    return ProductSpecificationModel(
      key: json['key'] as Map<String, dynamic>?,
      value: json['value'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }

  ProductSpecificationModel copyWith({
    Map<String, dynamic>? key,
    Map<String, dynamic>? value,
  }) {
    return ProductSpecificationModel(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}
