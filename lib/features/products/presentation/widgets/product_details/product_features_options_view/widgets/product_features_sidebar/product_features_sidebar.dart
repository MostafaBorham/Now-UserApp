import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sidebar/widgets/product_features_sidebar_item.dart';

class ProductFeaturesSidebar extends StatelessWidget {
  const ProductFeaturesSidebar({
    super.key,
    required this.selectedIndex,
    this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        border: BorderDirectional(
          end: BorderSide(color: context.colors.neutral200),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          spacing: 8,
          children: List.generate(
            2,
            (section) => ProductFeaturesSidebarItem(
              title: section == 0
                  ? LangKeys.colorKey.tr()
                  : LangKeys.sizeKey.tr(),
              isSelected: section == selectedIndex,
              onTap: () => onSelected?.call(section),
            ),
          ),
        ),
      ),
    );
  }
}
