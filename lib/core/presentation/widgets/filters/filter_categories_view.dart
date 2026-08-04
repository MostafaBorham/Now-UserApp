import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class FilterCategoriesView extends StatelessWidget {
  const FilterCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<String> types = [
      LangKeys.allKey.tr(),
      LangKeys.topRatedKey.tr(),
      LangKeys.mostPopularKey.tr(),
    ];
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
          items: types,
          initialIndex: 0,
          onChanged: (index) {
          },
          labelColor: colors.black,
          selectedColor: colors.surfaceContainerHigh,
          radius: 999,
          selectedLabelColor: colors.black,
          borderColor: Colors.transparent,
          unselectedColor: colors.neutral500.withValues(alpha: 0.1),
        )
      ],
    );
  }
}