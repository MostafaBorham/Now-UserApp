import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/sticky_on_scroll.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';

/// The `all_stores` section: a category filter over a list of stores.
///
/// **All** shows the feed's own `all_stores` items ([stores]) — the admin's
/// pick and order for this section, already carrying the user's
/// `is_favourite` — with no request of its own. **Every category tab** fetches
/// that category's stores on demand (`getCategoryStoresProvider`).
class HomeAllStoresSectionView extends ConsumerStatefulWidget {
  const HomeAllStoresSectionView({
    super.key,
    required this.stores,
    this.pinTop,
  });

  final List<StoreModel> stores;

  /// When set, the tab bar pins this many pixels below the viewport top (i.e.
  /// right under the pinned search bar) as the page scrolls. Null disables it.
  final ValueListenable<double>? pinTop;

  @override
  ConsumerState<HomeAllStoresSectionView> createState() =>
      _HomeAllStoresSectionViewState();
}

class _HomeAllStoresSectionViewState
    extends ConsumerState<HomeAllStoresSectionView>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;

  // The pills row (CustomButtonTabBar's TabBar). The store list starts a
  // small gap below it and scrolls with the page, while the pills stay parked
  // here once pinned.
  static const double _pillsRowHeight = 48;
  static const double _listTop = _pillsRowHeight + 8;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

    final List<Widget> views = <Widget>[
      HomeStoresListView(
        stores: widget.stores,
        onFavouriteChanged: (int? storeId, bool isFavourite) => ref
            .read(getHomeSectionsProvider.notifier)
            .updateStoreFavourite(storeId, isFavourite),
      ),
      ...categories.map(
        (CategoryModel category) =>
            _HomeCategoryStoresListView(category: category),
      ),
    ];

    final int selectedIndex = _selectedIndex.clamp(0, tabs.length - 1);

    // Only the pill row is reserved: the bar's own 16 px gap and its TabBarView
    // (empty here — the list lives below) overflow unseen, instead of pushing
    // the stores ~23 px further down (BUG-024).
    Widget pills = SizedBox(
      height: _pillsRowHeight,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: _pillsRowHeight + 16,
        child: CustomButtonTabBar(
          tabs: tabs,
          views: List<Widget>.filled(tabs.length, const SizedBox.shrink()),
          onTap: (int index) {
            if (index == _selectedIndex) return;
            if (index > 0) {
              ref.invalidate(
                getCategoryStoresProvider(
                  _HomeCategoryStoresListView.argsOf(categories[index - 1]),
                ),
              );
            }
            setState(() => _selectedIndex = index);
          },
          unSelectedTabColor: colors.neutral500.withValues(alpha: 0.2),
        ),
      ),
    );
    final ValueListenable<double>? pinTop = widget.pinTop;
    if (pinTop != null) {
      pills = StickyOnScroll(
        pinTop: pinTop,
        background: Theme.of(context).scaffoldBackgroundColor,
        // The section is inset by 16; bleed the pinned backdrop back out to the
        // screen edges so scrolling cards don't show through beside the pills.
        horizontalBleed: 16,
        child: pills,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
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
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: _listTop),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: views[selectedIndex],
                ),
              ),
              pills,
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeCategoryStoresListView extends ConsumerWidget {
  const _HomeCategoryStoresListView({required this.category});

  final CategoryModel category;

  static CategoryStoresArgs argsOf(CategoryModel category) =>
      (categorySlug: category.slug ?? '', categoryId: null, searchKey: null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CategoryStoresArgs args = argsOf(category);
    final AsyncValue<PaginationModel<StoreModel>> state = ref.watch(
      getCategoryStoresProvider(args),
    );

    return state.when(
      loading: () => _StoresList(
        itemCount: HomeStoresListView.itemCount,
        itemBuilder: (context, index) => AppShimmer(child: StoreCardView()),
      ),
      error: (Object error, _) => ServerConnectionErrorWidget(
        message: error is String ? error : null,
        onRetry: () =>
            ref.read(getCategoryStoresProvider(args).notifier).loadFirstPage(),
      ),
      data: (PaginationModel<StoreModel> page) => HomeStoresListView(
        stores: page.data,
        onFavouriteChanged: (int? storeId, bool isFavourite) => ref
            .read(getCategoryStoresProvider(args).notifier)
            .updateStoreFavourite(storeId, isFavourite),
      ),
    );
  }
}

class HomeStoresListView extends StatelessWidget {
  const HomeStoresListView({
    super.key,
    required this.stores,
    required this.onFavouriteChanged,
  });

  final List<StoreModel> stores;
  final void Function(int? storeId, bool isFavourite) onFavouriteChanged;

  static const int itemCount = 7;
  static const double separator = 15;

  // The store card cover scales with width (w * 0.32) while its text block is a
  // roughly constant ~110px, so this tracks the card's natural height closely.
  static double itemHeight(double width) => width * 0.32 + 110;

  @override
  Widget build(BuildContext context) {
    final List<StoreModel> shown = stores.take(itemCount).toList();
    if (shown.isEmpty) {
      return NoResultsWidget(emptyMessage: LangKeys.noStoresYetKey.tr());
    }
    return _StoresList(
      itemCount: shown.length,
      itemBuilder: (context, index) => StoreCardView(
        store: shown[index],
        onFavouriteChanged: (bool isFavourite) =>
            onFavouriteChanged(shown[index].id, isFavourite),
      ),
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
          padding: EdgeInsets.only(bottom: 5),
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
