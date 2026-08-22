import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class FilterCategoriesView extends StatelessWidget {
  const FilterCategoriesView({super.key, required this.categories, this.selectedColor, this.selectedLabelColor});

  final List<CategoryModel> categories;
  final Color? selectedColor;
  final Color? selectedLabelColor;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          LangKeys.categoriesKey.tr(),
          style: AppTextStyles.style16Medium.copyWith(
            color: colors.neutral1200,
          ),
        ),
        AppSelector(
          items: categories.map((category) => context.getLocalizedApiText(category.name),).toList(),
          initialIndex: 0,
          onChanged: (index) {
          },
          labelColor: colors.black,
          selectedColor: selectedColor?? colors.surfaceContainerHigh,
          radius: 999,
          selectedLabelColor: selectedLabelColor?? colors.black,
          borderColor: Colors.transparent,
          unselectedColor: colors.neutral500.withValues(alpha: 0.1),
        )
      ],
    );
  }
}