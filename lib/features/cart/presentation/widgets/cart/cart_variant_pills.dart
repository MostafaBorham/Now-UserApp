import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The selected variant of a cart line, shown as a wrap of pills: a colored
/// swatch for `options.color` (the API gives only a hex, no name), then one
/// value pill per selected attribute value (`Medium`, `Polyester`, …).
///
/// Reads the raw `options` map straight off the [ProductModel] cart line so the
/// core model stays untyped. Renders nothing when there is no variant to show.
class CartVariantPills extends StatelessWidget {
  const CartVariantPills({super.key, required this.options});

  final Map<String, dynamic>? options;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? options = this.options;
    if (options == null) return const SizedBox.shrink();

    final Color? swatch = colorFromHex(options['color'] as String?);
    final List<String> values = _valueLabels(context, options['attributes']);

    if (swatch == null && values.isEmpty) return const SizedBox.shrink();

    final AppColorScheme colors = context.colors;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (swatch != null) _swatchPill(colors, swatch),
        for (final String value in values) _textPill(colors, value),
      ],
    );
  }

  /// Flattens `attributes[].values[].name` into localized value labels, skipping
  /// anything malformed rather than throwing on an unexpected shape.
  List<String> _valueLabels(BuildContext context, Object? attributes) {
    if (attributes is! List) return const <String>[];

    final List<String> labels = <String>[];
    for (final Object? attribute in attributes) {
      if (attribute is! Map) continue;
      final Object? values = attribute['values'];
      if (values is! List) continue;
      for (final Object? value in values) {
        if (value is! Map) continue;
        final Object? name = value['name'];
        final String label = context.getLocalizedApiText(
          name is Map<String, dynamic> ? name : null,
        );
        if (label.isNotEmpty) labels.add(label);
      }
    }
    return labels;
  }

  Widget _textPill(AppColorScheme colors, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.neutral200,
        borderRadius: AppBorderRadius.brCircular8,
      ),
      child: Text(
        label,
        style: AppTextStyles.style12Medium.copyWith(
          color: colors.tertiaryContainer,
        ),
      ),
    );
  }

  Widget _swatchPill(AppColorScheme colors, Color swatch) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.neutral200,
        borderRadius: AppBorderRadius.brCircular8,
      ),
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: swatch,
          shape: BoxShape.circle,
          border: Border.all(color: colors.neutral200),
        ),
      ),
    );
  }
}

/// Parses a `#RRGGBB` / `RRGGBB` (or `#AARRGGBB`) hex string into a [Color].
/// Returns `null` for null, empty or malformed input — the caller then draws no
/// swatch rather than a wrong color.
Color? colorFromHex(String? hex) {
  if (hex == null) return null;
  String value = hex.trim();
  if (value.startsWith('#')) value = value.substring(1);
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final int? argb = int.tryParse(value, radix: 16);
  return argb == null ? null : Color(argb);
}
