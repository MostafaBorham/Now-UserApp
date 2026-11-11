import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_size_options/widgets/product_features_size_option_item.dart';

class ProductFeaturesSizeOptions extends StatelessWidget {
  const ProductFeaturesSizeOptions({
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
        4,
        (option) => ProductFeaturesSizeOptionItem(
          label: LangKeys.size16InchKey.tr(),
          isSelected: option == selectedIndex,
          onTap: () => onSelected?.call(option),
        ),
      ),
    );
  }
}
