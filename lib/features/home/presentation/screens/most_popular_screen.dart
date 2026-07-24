import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/most_popular/views/all_most_popular_filter_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/most_popular/views/most_popular_filter_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/most_popular/cards/most_popular_slider_item_card.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';

class MostPopularScreen extends StatelessWidget {
  const MostPopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedView(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: AppSlider(
                itemAspectRatio: 0.9,
                sliderItems: [MostPopularSliderItemCard()],
                activeDotColor: colors.primaryFixedDim,
                dotColor: colors.inversePrimary.withValues(alpha: 0.5),
              ),
            ),
            SliverToBoxAdapter(child: 10.hSpace),
          ],
          body: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(LangKeys.filtersKey),
                style: AppTextStyles.style14SemiBold.copyWith(
                  color: colors.onSecondary,
                ),
              ),
              Expanded(
                child: CustomButtonTabBar(
                  tabs: [LangKeys.allKey.tr(), 'Perfumes', 'Shoes', 'Devices'],
                  views: [
                    AllMostPopularFilterView(),
                    MostPopularFilterView(filterName: 'Perfumes'),
                    MostPopularFilterView(filterName: 'Shoes'),
                    MostPopularFilterView(filterName: 'Devices'),
                  ],
                  selectedTabColor: colors.secondary.withValues(alpha: 0.8),
                  unSelectedTabColor: colors.inversePrimary.withValues(
                    alpha: 0.2,
                  ),
                  selectedLabelColor: colors.onSecondary,
                  unSelectedLabelColor: colors.onSecondary,
                ),
              ),
            ],
          ),
        ),
        appBarTitle: context.tr(LangKeys.mostPopularKey),
      ),
    );
  }
}
