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
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/sticky_on_scroll.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';








class HomeAllStoresSectionView extends ConsumerStatefulWidget {
  const HomeAllStoresSectionView({
    super.key,
    this.pinTop,
    this.stores = const <StoreModel>[],
  });



  final ValueListenable<double>? pinTop;


  final List<StoreModel> stores;

  @override
  ConsumerState<HomeAllStoresSectionView> createState() =>
      _HomeAllStoresSectionViewState();
}

class _HomeAllStoresSectionViewState
    extends ConsumerState<HomeAllStoresSectionView> {
  int _selectedIndex = 0;



  static const double _pillsBarHeight = HomeStoresListView.tabRowHeight;

  @override
  Widget build(BuildContext context) {
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
      HomeStoresListView(stores: widget.stores),
      ...categories.map(
        (CategoryModel category) => HomeStoresListView(category: category),
      ),
    ];

    final int selectedIndex = _selectedIndex.clamp(0, tabs.length - 1);

    Widget pills = SizedBox(
      height: _pillsBarHeight,
      child: CustomButtonTabBar(
        tabs: tabs,
        views: List<Widget>.filled(tabs.length, const SizedBox.shrink()),
        onTap: (int index) {
          if (index == _selectedIndex) return;


          final CategoryModel? category =
              index == 0 ? null : categories[index - 1];
          if (category != null) {
            ref.invalidate(
              getCategoryStoresProvider((
                categorySlug: category.slug ?? '',
                categoryId: null,
                searchKey: null,
              )),
            );
          }
          setState(() => _selectedIndex = index);
        },
        unSelectedTabColor: colors.neutral500.withValues(alpha: 0.2),
      ),
    );
    final ValueListenable<double>? pinTop = widget.pinTop;
    if (pinTop != null) {
      pills = StickyOnScroll(
        pinTop: pinTop,
        background: Theme.of(context).scaffoldBackgroundColor,


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
                padding: const EdgeInsets.only(top: _pillsBarHeight),
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



class HomeStoresListView extends ConsumerWidget {
  const HomeStoresListView({
    super.key,
    this.category,
    this.stores = const <StoreModel>[],
  });

  final CategoryModel? category;
  final List<StoreModel> stores;

  static const int itemCount = 7;
  static const double separator = 15;




  static const double tabRowHeight = 66;



  static double itemHeight(double width) => width * 0.32 + 110;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CategoryModel? category = this.category;
    if (category == null) {


      final List<StoreModel> all = stores.take(itemCount).toList();
      if (all.isEmpty) return const NoResultsWidget();
      return _StoresList(
        itemCount: all.length,
        itemBuilder: (context, index) => StoreCardView(store: all[index]),
      );
    }

    final CategoryStoresArgs args = (
      categorySlug: category.slug ?? '',
      categoryId: null,
      searchKey: null,
    );
    final AsyncValue<PaginationModel<StoreModel>> state = ref.watch(
      getCategoryStoresProvider(args),
    );

    return state.when(
      loading: () => _StoresList(
        itemCount: itemCount,
        itemBuilder: (context, index) => AppShimmer(child: StoreCardView()),
      ),
      error: (Object error, _) => ServerConnectionErrorWidget(
        message: error is String ? error : null,
        onRetry: () =>
            ref.read(getCategoryStoresProvider(args).notifier).loadFirstPage(),
      ),
      data: (PaginationModel<StoreModel> page) {
        final List<StoreModel> stores = page.data.take(itemCount).toList();
        if (stores.isEmpty) return const NoResultsWidget();
        return _StoresList(
          itemCount: stores.length,
          itemBuilder: (context, index) => StoreCardView(
            store: stores[index],
            onFavouriteChanged: (bool isFavourite) => ref
                .read(getCategoryStoresProvider(args).notifier)
                .updateStoreFavourite(stores[index].id, isFavourite),
          ),
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
