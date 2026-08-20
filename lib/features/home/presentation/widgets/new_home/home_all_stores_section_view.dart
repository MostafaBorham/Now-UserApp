import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_store_item_view.dart';

class HomeAllStoresSectionView extends ConsumerWidget {
  const HomeAllStoresSectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;

    final AsyncValue<PaginationModel<CategoryModel>> categoriesState = ref
        .watch(getAppCategoriesProvider);
    final List<CategoryModel> categories =
        categoriesState.valueOrNull?.data ?? const <CategoryModel>[];

    final List<String> tabs = <String>[
      LangKeys.allKey.tr(),
      ...categories.map(
        (CategoryModel category) => context.getLocalizedApiText(category.name),
      ),
    ];

    // The "All" tab (no category) shows demo placeholder cards; every other tab
    // is bound to its own CategoryModel and fetches that category's stores.
    final List<Widget> views = <Widget>[
      const HomeStoresListView(),
      ...categories.map(
        (CategoryModel category) => HomeStoresListView(category: category),
      ),
    ];

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
                child: CustomButtonTabBar(
                  tabs: tabs,
                  views: views,
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

class HomeStoresListView extends ConsumerWidget {
  const HomeStoresListView({super.key, this.category});

  final CategoryModel? category;

  static const int itemCount = 7;
  static const double separator = 15;

  static const double horizontalInset = 10;

  // Generous, fixed height for the tab row above the list so the computed
  // tab-area height never clips the list.
  static const double tabRowHeight = 60;

  // The store card cover scales with width (w * 0.32) while its text block is a
  // roughly constant ~110px, so this tracks the card's natural height closely.
  static double itemHeight(double width) => width * 0.32 + 110;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CategoryModel? category = this.category;
    // "All" tab: no data source wired yet — demo placeholder cards.
    if (category == null) {
      return _StoresList(
        itemCount: itemCount,
        itemBuilder: (context, index) => const HomeStoreItemView(),
      );
    }

    final CategoryStoresArgs args = (
      categorySlug: category.slug ?? '',
      categoryId: null,
    );
    final AsyncValue<PaginationModel<StoreModel>> state = ref.watch(
      getCategoryStoresProvider(args),
    );

    return state.when(
      loading: () => _StoresList(
        itemCount: itemCount,
        itemBuilder: (context, index) => AppShimmer(child: HomeStoreItemView()),
      ),
      error: (Object error, _) => ServerConnectionErrorWidget(
        message: error is String ? error : null,
        onRetry: () =>
            ref.read(getCategoryStoresProvider(args).notifier).loadFirstPage(),
      ),
      data: (PaginationModel<StoreModel> page) {
        final List<StoreModel> stores = page.data.take(itemCount).toList();
        if (stores.isEmpty) return const NoItemsWidget();
        return _StoresList(
          itemCount: stores.length,
          itemBuilder: (context, index) =>
              HomeStoreItemView(store: stores[index]),
        );
      },
    );
  }
}

class _StoresList extends StatelessWidget {
  const _StoresList({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = HomeStoresListView.itemHeight(
          constraints.maxWidth,
        );
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          addRepaintBoundaries: true,
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          itemBuilder: (context, index) =>
              SizedBox(height: height, child: itemBuilder(context, index)),
          separatorBuilder: (context, index) =>
              const SizedBox(height: HomeStoresListView.separator),
        );
      },
    );
  }
}
