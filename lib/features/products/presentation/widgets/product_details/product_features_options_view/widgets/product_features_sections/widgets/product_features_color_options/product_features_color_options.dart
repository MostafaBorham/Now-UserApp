import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_color_options/widgets/product_features_color_option_item.dart';

class ProductFeaturesColorOptions extends StatelessWidget {
  const ProductFeaturesColorOptions({
    super.key,
    required this.selectedIndex,
    this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        5,
        (option) => ProductFeaturesColorOptionItem(
          name: LangKeys.colorBlackKey.tr(),
          color: context.colors.neutral1100,
          isSelected: option == selectedIndex,
          onTap: () => onSelected?.call(option),
        ),
      ),
    );
  }
}
