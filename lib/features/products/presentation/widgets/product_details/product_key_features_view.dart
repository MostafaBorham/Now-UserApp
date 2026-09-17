import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ProductKeyFeaturesView extends StatefulWidget {
  const ProductKeyFeaturesView({super.key, required this.productFeatures});

  final List<String> productFeatures;

  @override
  State<ProductKeyFeaturesView> createState() => _ProductKeyFeaturesViewState();
}

class _ProductKeyFeaturesViewState extends State<ProductKeyFeaturesView> {
  late String _parsedFeatures = _parse(widget.productFeatures);

  @override
  void didUpdateWidget(covariant ProductKeyFeaturesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.productFeatures, widget.productFeatures)) {
      _parsedFeatures = _parse(widget.productFeatures);
    }
  }

  String _parse(List<String> features) => features
      .map((feature) => html_parser.parse(feature).body?.text.trim() ?? '')
      .where((text) => text.isNotEmpty)
      .join('\n');

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          LangKeys.keyFeaturesKey.tr(),
          style: AppTextStyles.style16Bold.copyWith(
            color: colors.black,
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.neutral500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _parsedFeatures,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: AppTextStyles.style14Medium.copyWith(
              color: colors.black,
              height: 1.5,
            ),
          ),
        )
      ],
    );
  }
}
