import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_attribute_model.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_color_model.dart';

class ProductOptions {
  const ProductOptions({
    this.colorHex,
    this.attributeValueIds = const {},
  });

  final String? colorHex;
  final Map<String, int> attributeValueIds;

  ProductOptions copyWith({
    String? colorHex,
    Map<String, int>? attributeValueIds,
  }) {
    return ProductOptions(
      colorHex: colorHex ?? this.colorHex,
      attributeValueIds: attributeValueIds ?? this.attributeValueIds,
    );
  }

  Map<String, dynamic>? toBody() {
    final Map<String, dynamic> body = <String, dynamic>{};

    if (colorHex != null && colorHex!.isNotEmpty) {
      body['color'] = colorHex;
    }

    if (attributeValueIds.isNotEmpty) {
      body['attributes'] = attributeValueIds.entries
          .map(
            (MapEntry<String, int> entry) => <String, dynamic>{
              'attribute_id': entry.key,
              'value_ids': <int>[entry.value],
            },
          )
          .toList();
    }

    return body.isEmpty ? null : body;
  }
}

final productOptionsProvider = StateNotifierProvider.autoDispose
    .family<ProductOptionsNotifier, ProductOptions, int>(
  (Ref ref, int productId) => ProductOptionsNotifier(),
);

class ProductOptionsNotifier extends StateNotifier<ProductOptions> {
  ProductOptionsNotifier() : super(const ProductOptions());

  bool _seeded = false;

  void seedDefaults(ProductModel product) {
    if (_seeded) return;
    _seeded = true;

    final List<ProductColorModel> colors = product.colors ?? const [];

    final Map<String, int> attributes = <String, int>{};
    for (final ProductAttributeModel attribute
        in product.attributes ?? const []) {
      final String? attributeId = attribute.attributeId;
      final List<ProductAttributeValueModel> values =
          attribute.values ?? const [];
      if (attributeId != null && values.isNotEmpty && values.first.id != null) {
        attributes[attributeId] = values.first.id!;
      }
    }

    state = ProductOptions(
      colorHex: colors.isNotEmpty ? colors.first.hex : null,
      attributeValueIds: attributes,
    );
  }

  void selectColor(String? hex) {
    state = state.copyWith(colorHex: hex);
  }

  void selectAttributeValue(String attributeId, int valueId) {
    final Map<String, int> updated =
        Map<String, int>.from(state.attributeValueIds);
    updated[attributeId] = valueId;
    state = state.copyWith(attributeValueIds: updated);
  }
}
