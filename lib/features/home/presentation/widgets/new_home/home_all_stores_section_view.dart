import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_store_item_view.dart';

/// The home "all stores" section: a category-filtered tab bar over the store
/// cards, plus a "see all" shortcut into [AllStoresScreen].
///
/// The tabs are sourced from the shared [getAppCategoriesProvider] (preloaded on
/// splash and also driven by the home categories carousel) and depend on its
/// state:
/// * **loading** (no data yet) → a shimmer placeholder row, no **All** tab;
/// * **error** (no data) → the **All** tab only;
/// * **data** → the pinned **All** tab followed by one tab per app category,
///   each bound to a [CategoryModel] and labelled with its localized name.
class HomeAllStoresSectionView extends ConsumerWidget {
  const HomeAllStoresSectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;

    final AsyncValue<PaginationModel<CategoryModel>> categoriesState = ref.watch(
      getAppCategoriesProvider,
    );
    final PaginationModel<CategoryModel>? categoriesPage =
        categoriesState.valueOrNull;
    final bool showTabsShimmer =
        categoriesPage == null && categoriesState.isLoading;
    final List<String> tabs = <String>[
      LangKeys.allKey.tr(),
      ...(categoriesPage?.data ?? const <CategoryModel>[]).map(
        (CategoryModel category) => context.getLocalizedApiText(category.name),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                    LangKeys.allStoresKey.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.black,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.pushNamed(AppRoutes.allStoresScreen),
                    child: Text(
                      LangKeys.seeAllKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: tabBarHeight,
                child: showTabsShimmer
                    ? Column(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: HomeStoresListView.tabRowHeight,
                            child: AppShimmer(
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount:
                                    HomeStoresListView.shimmerTabWidths.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) => Center(
                                  child: Container(
                                    width:
                                        HomeStoresListView.shimmerTabWidths[index],
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: colors.neutral500,
                                      borderRadius: AppBorderRadius.brCircular20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const HomeStoresListView(),
                        ],
                      )
                    : CustomButtonTabBar(
                        key: ValueKey<int>(tabs.length),
                        tabs: tabs,
                        views: List<Widget>.generate(
                          tabs.length,
                          (_) => const HomeStoresListView(),
                        ),
                        // selectedTabColor: colors.primary500Main,
                        unSelectedTabColor: colors.neutral500.withValues(
                          alpha: 0.2,
                        ),
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

  static const double horizontalInset = 10;

  // Generous, fixed height for the tab row above the list so the computed
  // tab-area height never clips the list.
  static const double tabRowHeight = 60;

  // Placeholder pill widths for the loading tab row — varied so the shimmer
  // reads as a row of differently-sized tabs rather than identical blocks.
  static const List<double> shimmerTabWidths = [64, 92, 78, 96];

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
          separatorBuilder: (context, index) =>
              const SizedBox(height: separator),
          itemCount: itemCount,
        );
      },
    );
  }
}
