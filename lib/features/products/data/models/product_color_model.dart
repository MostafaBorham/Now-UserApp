import 'dart:ui';

/// A single selectable colour of a product as sent by the API under the
/// `colors` list, e.g.
/// ```json
/// { "hex": "#374151", "name": { "ar": "رمادي داكن", "en": "Charcoal" } }
/// ```
class ProductColorModel {
  /// The raw `#RRGGBB` (or `#AARRGGBB`) hex string as sent by the backend.
  final String? hex;

  /// The localized display name as a `{ar, en}` translation map.
  final Map<String, dynamic>? name;

  const ProductColorModel({this.hex, this.name});

  /// [hex] parsed into a [Color] for the swatch, or `null` when absent or
  /// malformed so callers can fall back to a theme colour instead of rendering
  /// a broken one.
  Color? get color {
    final String value = (hex ?? '').replaceFirst('#', '');
    if (value.length != 6 && value.length != 8) return null;
    final int? parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;
    return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
  }

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawName = json['name'];
    return ProductColorModel(
      hex: json['hex']?.toString(),
      name: rawName is String
          ? {'ar': rawName, 'en': rawName}
          : rawName as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hex': hex,
      'name': name,
    };
  }

  ProductColorModel copyWith({String? hex, Map<String, dynamic>? name}) {
    return ProductColorModel(
      hex: hex ?? this.hex,
      name: name ?? this.name,
    );
  }
}
