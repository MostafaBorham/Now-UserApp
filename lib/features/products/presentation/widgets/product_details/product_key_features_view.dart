import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ProductKeyFeaturesView extends StatelessWidget {
  const ProductKeyFeaturesView({super.key, required this.productFeatures});

  final List<String> productFeatures;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          LangKeys.keyFeaturesKey.tr(),
          style: AppTextStyles.style16Bold.copyWith(
            color: colors.onSecondary,
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            spacing: 16,
            children: productFeatures.map(
              (feature) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: CircleAvatar(
                      radius: 2,
                      backgroundColor: colors.onSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      feature,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: AppTextStyles.style14Medium.copyWith(
                        color: colors.onSecondary,
                        height: 1.5,
                      ),
                    ),
                  )
                ],
              ),
            ).toList(),
          ),
        )
      ],
    );
  }
}
