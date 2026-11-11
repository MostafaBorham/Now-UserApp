import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/scroll_spy/sections_scroll_spy.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/scroll_spy/sections_scroll_view.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_color_options/product_features_color_options.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_section_card/product_features_section_card.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_size_options/product_features_size_options.dart';

class ProductFeaturesSections extends StatelessWidget {
  const ProductFeaturesSections({
    super.key,
    required this.scrollSpy,
    required this.collapsedSectionIndexes,
    required this.selectedOptionIndexes,
    this.onSectionToggled,
    this.onOptionSelected,
  });

  final SectionsScrollSpy scrollSpy;
  final Set<int> collapsedSectionIndexes;
  final Map<int, int> selectedOptionIndexes;
  final ValueChanged<int>? onSectionToggled;
  final void Function(int section, int option)? onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return SectionsScrollView(
      scrollSpy: scrollSpy,
      sectionsCount: 2,
      sectionBuilder: (section) {
        final int selectedOption = selectedOptionIndexes[section] ?? 0;
        void selectOption(int option) =>
            onOptionSelected?.call(section, option);
        return ProductFeaturesSectionCard(
          title: section == 0 ? LangKeys.colorKey.tr() : LangKeys.sizeKey.tr(),
          isCollapsed: collapsedSectionIndexes.contains(section),
          onToggle: () => onSectionToggled?.call(section),
          child: section == 0
              ? ProductFeaturesColorOptions(
                  selectedIndex: selectedOption,
                  onSelected: selectOption,
                )
              : ProductFeaturesSizeOptions(
                  selectedIndex: selectedOption,
                  onSelected: selectOption,
                ),
        );
      },
    );
  }
}
