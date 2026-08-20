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

class HomeAllStoresSectionView extends ConsumerStatefulWidget {
  const HomeAllStoresSectionView({super.key});

  @override
  ConsumerState<HomeAllStoresSectionView> createState() =>
      _HomeAllStoresSectionViewState();
}

class _HomeAllStoresSectionViewState
    extends ConsumerState<HomeAllStoresSectionView> {
  // Which tab is currently visible. The tab area is sized to fit only this
  // tab's content, so error/empty tabs stay compact while list tabs get the
  // full height they need.
  int _selectedIndex = 0;

  // Natural height of the currently shown error/empty widget, measured offstage
  // (see [_MeasureSize]). Kept per tab so switching tabs doesn't flash a stale
  // height. Null until the first measure completes.
  final Map<int, double> _compactHeights = <int, double>{};

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

    // The "All" tab (no category) shows demo placeholder cards; every other tab
    // is bound to its own CategoryModel and fetches that category's stores.
    final List<Widget> views = <Widget>[
      const HomeStoresListView(),
      ...categories.map(
        (CategoryModel category) => HomeStoresListView(category: category),
      ),
    ];

    // Tabs can shrink (e.g. categories reloading); keep the selection valid.
    final int selectedIndex = _selectedIndex.clamp(0, tabs.length - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fullListHeight = HomeStoresListView.listHeight(
            HomeStoresListView.itemCount,
            constraints.maxWidth,
          );

          // Resolve how much room the currently visible tab actually needs.
          // For list/loading tabs it's the full list height; for error/empty
          // tabs it's the widget's own measured height, so the tab area (and
          // therefore the page scroll) never reserves the tall list height for
          // a short error state.
          final _TabContent content = _resolveSelectedContent(
            selectedIndex: selectedIndex,
            categories: categories,
            outerWidth: constraints.maxWidth,
            fullListHeight: fullListHeight,
          );

          final double tabBarHeight =
              HomeStoresListView.tabRowHeight + 16 + content.height;

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
                  onTap: (int index) {
                    if (index != _selectedIndex) {
                      setState(() => _selectedIndex = index);
                    }
                  },
                  unSelectedTabColor: colors.neutral500.withValues(alpha: 0.2),
                ),
              ),
              // Offstage measurer for the compact (error/empty) states: renders
              // the same widget with an unbounded height to read its natural
              // size, then feeds it back so the tab area can shrink to fit.
              if (content.measure != null)
                Offstage(
                  child: SizedBox(
                    width: constraints.maxWidth - HomeStoresListView.horizontalInset,
                    child: _MeasureSize(
                      onChange: (Size size) {
                        if (!mounted) return;
                        final double measured = size.height;
                        if (_compactHeights[selectedIndex] != measured) {
                          setState(
                            () => _compactHeights[selectedIndex] = measured,
                          );
                        }
                      },
                      child: content.measure!,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Resolves the content height for the currently selected tab, plus the widget
  /// that must be measured offstage when the tab is in a compact (error/empty)
  /// state. List/loading tabs need no measuring — their height is computed.
  _TabContent _resolveSelectedContent({
    required int selectedIndex,
    required List<CategoryModel> categories,
    required double outerWidth,
    required double fullListHeight,
  }) {
    // "All" tab: always the full demo list.
    if (selectedIndex == 0) {
      return _TabContent(height: fullListHeight);
    }

    final int categoryIndex = selectedIndex - 1;
    if (categoryIndex >= categories.length) {
      return _TabContent(height: fullListHeight);
    }

    final CategoryModel category = categories[categoryIndex];
    final CategoryStoresArgs args = (
      categorySlug: category.slug ?? '',
      categoryId: null,
    );
    final AsyncValue<PaginationModel<StoreModel>> state = ref.watch(
      getCategoryStoresProvider(args),
    );

    return state.when(
      // Shimmer shows the full list of placeholders.
      loading: () => _TabContent(height: fullListHeight),
      error: (Object error, _) {
        final Widget widget = ServerConnectionErrorWidget(
          message: error is String ? error : null,
          onRetry: () => ref
              .read(getCategoryStoresProvider(args).notifier)
              .loadFirstPage(),
        );
        return _TabContent(
          // Fall back to the full height until measured, so the first frame
          // never clips the error widget (incl. its retry button).
          height: _compactHeights[selectedIndex] ?? fullListHeight,
          measure: widget,
        );
      },
      data: (PaginationModel<StoreModel> page) {
        final int count = page.data.take(HomeStoresListView.itemCount).length;
        if (count == 0) {
          return _TabContent(
            height: _compactHeights[selectedIndex] ?? fullListHeight,
            measure: const NoItemsWidget(),
          );
        }
        return _TabContent(
          height: HomeStoresListView.listHeight(count, outerWidth),
        );
      },
    );
  }
}

/// The resolved height for the selected tab and, for compact states, the widget
/// whose natural height must be measured offstage.
class _TabContent {
  const _TabContent({required this.height, this.measure});

  final double height;
  final Widget? measure;
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

  /// Total height of a list of [count] cards laid out at full height inside an
  /// area of [outerWidth]. Single source of truth for the list's own height and
  /// for the section that reserves room for it.
  static double listHeight(int count, double outerWidth) {
    if (count <= 0) return 0;
    final double width = outerWidth - horizontalInset;
    return count * itemHeight(width) + (count - 1) * separator;
  }

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

/// Reports the laid-out size of [child] via [onChange] after each frame. Used to
/// read the natural height of the error/empty widgets when they are rendered in
/// an unbounded (offstage) box, so the tab area can shrink to fit them.
class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx = _key.currentContext;
      if (ctx == null) return;
      final RenderBox box = ctx.findRenderObject() as RenderBox;
      if (box.hasSize) widget.onChange(box.size);
    });
    return SizedBox(key: _key, child: widget.child);
  }
}
