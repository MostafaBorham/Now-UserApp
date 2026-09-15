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
