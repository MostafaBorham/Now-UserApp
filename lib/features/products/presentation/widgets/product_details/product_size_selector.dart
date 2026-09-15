import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';
import 'package:nowdelivery_user_app/features/products/data/models/product_attribute_model.dart';

class ProductSizeSelector extends StatelessWidget {
  const ProductSizeSelector({
    super.key,
    required this.attribute,
    this.hint,
    this.isRequired = true,
    this.initialSelectedIndex = 0,
    this.onValueSelected,
  });

  final ProductAttributeModel attribute;
  final String? hint;
  final bool isRequired;
  final int initialSelectedIndex;

  final ValueChanged<ProductAttributeValueModel>? onValueSelected;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String title = context.getLocalizedApiText(attribute.name);
    final String hint = this.hint ?? LangKeys.selectRequiredKey.tr();
    final List<ProductAttributeValueModel> values = attribute.values ?? [];
    final List<String> options = values
        .map((value) => context.getLocalizedApiText(value.name))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Text(
              title,
              style: AppTextStyles.style16Bold.copyWith(
                color: colors.black,
              ),
            ),
            if (isRequired)
              Text.rich(
                TextSpan(
                  text: '($hint) ',
                  style: AppTextStyles.style10Medium.copyWith(
                    color: colors.onPrimaryFixed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: colors.errorContainer),
                    ),
                  ],
                ),
              ),
          ],
        ),
        AppSelector(
          items: options,
          initialIndex: initialSelectedIndex,
          selectedColor: colors.tertiaryContainer,
          unselectedColor: colors.white,
          borderColor: colors.neutral500.withValues(alpha: 0.3),
          radius: 14,
          height: 45,
          onChanged: (index) => onValueSelected?.call(values[index]),
        ),
      ],
    );
  }
}
