import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/top_brands/top_brands_view.dart';

class TopBrandsScreen extends StatelessWidget {
  const TopBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: Column(
          spacing: 11,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSearchField(hintText: context.tr(LangKeys.searchForBrandKey)),
            6.hSpace,
            Text(
              context.tr(LangKeys.categoriesKey),
              style: AppTextStyles.style14SemiBold.copyWith(
                color: colors.onSecondary,
              ),
            ),
            Expanded(
              child: CustomButtonTabBar(
                tabs: ['All', 'Devices','sddssdsd','aaaaaaa'],
                views: [
                  TopBrandsView(),
                  TopBrandsView(),
                  TopBrandsView(),
                  TopBrandsView(),
                ],
                selectedTabColor: colors.secondary.withValues(alpha: 0.8),
                unSelectedTabColor: colors.inversePrimary.withValues(alpha: 0.2),
                selectedLabelColor: colors.onSecondary,
                unSelectedLabelColor: colors.onSecondary,
              ),
            ),
          ],
        ),
        appBarTitle: context.tr(LangKeys.topBrandsKey),
      ),
    );
  }
}
