import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/search/primary_search_field.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/top_brands/top_brands_view.dart';

class TopBrandsScreen extends StatelessWidget {
  const TopBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Scaffold(
      body: AppWavedView(
        body: Column(
          spacing: 11,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimarySearchField(isAnimated: false,),
            6.hSpace,
            Text(
              context.tr(LangKeys.categoriesKey),
              style: AppTextStyles.style14SemiBold.copyWith(
                color: colors.black,
              ),
            ),
            Expanded(
              child: CustomButtonTabBar(
                tabs: [LangKeys.allKey.tr(), 'Devices', 'sddssdsd', 'aaaaaaa'],
                views: [
                  TopBrandsView(),
                  TopBrandsView(),
                  TopBrandsView(),
                  TopBrandsView(),
                ],
                unSelectedTabColor: colors.neutral200.withValues(alpha: 0.5),

              ),
            ),
          ],
        ),
        appBarTitle: context.tr(LangKeys.topBrandsKey),
      ),
    );
  }
}
