import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/search/presentation/widgets/search_top_categories_list.dart';

class SearchCategoriesSection extends StatelessWidget {
  const SearchCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              LangKeys.bestCategoriesKey.tr(),
              style: AppTextStyles.style18SemiBold.copyWith(
                color: colors.black,
                fontSize: screenWidth * 0.05,
              ),
            ),
            InkWell(
              onTap: () =>
                  context.pushReplacementNamed(AppRoutes.categoriesScreen),
              child: Text(
                LangKeys.seeAllCategoriesKey.tr(),
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.primary500Main,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ],
        ),
        const SearchTopCategoriesList(),
      ],
    );
  }
}
