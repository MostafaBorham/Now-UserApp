import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/most_popular_slider_item.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/view/widgets/top_brands/top_brands_view.dart';

class MostPopularScreen extends StatelessWidget {
  const MostPopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSlider(
              itemAspectRatio: 0.9,
              sliderItem: MostPopularSliderItem(),
              activeDotColor: colors.primaryFixedDim,
              dotColor: colors.inversePrimary.withValues(alpha: 0.5),
            ),
            Text(
              context.tr(LangKeys.filtersKey),
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
        appBarTitle: context.tr(LangKeys.mostPopularKey),
      ),
    );
  }
}