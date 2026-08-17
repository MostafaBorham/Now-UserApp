import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/app_filter_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_store_item_view.dart';

class HomeAllStoresSectionView extends StatelessWidget {
  const HomeAllStoresSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // CustomButtonTabBar's TabBarView needs a bounded height, so we give
          // the whole tab area exactly enough room to lay out every store card
          // at full height. The outer page scroll then reveals all of them
          // instead of the inner list scrolling on its own.
          final double listWidth =
              constraints.maxWidth - HomeStoresListView.horizontalInset;
          final double listHeight =
              HomeStoresListView.itemCount *
                  HomeStoresListView.itemHeight(listWidth) +
              (HomeStoresListView.itemCount - 1) * HomeStoresListView.separator;
          final double tabBarHeight =
              HomeStoresListView.tabRowHeight + 16 + listHeight;
          return Column(
            spacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'جميع المتاجر',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.black,
                    ),
                  ),
                  Text(
                    'عرض الكل',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: tabBarHeight,
                child: CustomButtonTabBar(
                  filterWidget: AppFilterIcon(),
                  tabs: [
                    LangKeys.allKey.tr(),
                    ...['الأجهزة', 'الأحذية', 'الملابس'],
                  ],
                  views: [
                    HomeStoresListView(),
                    HomeStoresListView(),
                    HomeStoresListView(),
                    HomeStoresListView(),
                  ],
                  selectedTabColor: colors.primary500Main,
                  unSelectedTabColor: colors.neutral500.withValues(alpha: 0.2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HomeStoresListView extends StatelessWidget {
  const HomeStoresListView({super.key});

  static const int itemCount = 7;
  static const double separator = 15;

  // Horizontal space CustomButtonTabBar's TabBarView eats around each view
  // (EdgeInsets.symmetric(horizontal: 5)).
  static const double horizontalInset = 10;

  // Generous, fixed height for the tab row above the list so the computed
  // tab-area height never clips the list.
  static const double tabRowHeight = 60;

  // The store card cover scales with width (w * 0.32) while its text block is a
  // roughly constant ~110px, so this tracks the card's natural height closely.
  static double itemHeight(double width) => width * 0.32 + 110;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = itemHeight(constraints.maxWidth);
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          addRepaintBoundaries: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) =>
              SizedBox(height: height, child: const HomeStoreItemView()),
          separatorBuilder: (context, index) => const SizedBox(height: separator),
          itemCount: itemCount,
        );
      },
    );
  }
}
