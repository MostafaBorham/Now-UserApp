import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/pagination_scroll_listener.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_all_stores_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_products_vm.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_all_stores_vm.dart';

/// The results for [searchTerm]: the matching stores as a horizontal strip,
/// then the matching products as an infinite-scrolling grid, in one scroll.
///
/// `/api/v1/products` only matches product fields, so a store's name (e.g.
/// «النور») used to find nothing here. Stores come from `/api/v1/stores`,
/// which matches the store's Arabic and English name and description.
class SearchResultsView extends ConsumerWidget {
  const SearchResultsView({super.key, required this.searchTerm});

  final String searchTerm;

  static AllStoresArgs storesArgsOf(String searchTerm) =>
      (categoryId: null, rating: null, searchKey: searchTerm);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AllStoresArgs storesArgs = storesArgsOf(searchTerm);
    final GetProductsViewModel productsVm = ref.read(
      getProductsProvider(searchTerm).notifier,
    );

    final PaginationStatus<StoreModel> stores =
        PaginationStatus<StoreModel>.from(
          ref.watch(getAllStoresProvider(storesArgs)),
        );
    final PaginationStatus<ProductModel> products =
        PaginationStatus<ProductModel>.from(
          ref.watch(getProductsProvider(searchTerm)),
        );

    // Only "nothing at all" is an empty search. A store-only match leaves the
    // products part blank rather than saying there are no results under it.
    final bool nothingFound =
        stores.hasLoadedPage &&
        stores.isEmpty &&
        products.hasLoadedPage &&
        products.isEmpty;

    Future<void> refresh() => Future.wait(<Future<void>>[
      ref.read(getAllStoresProvider(storesArgs).notifier).loadFirstPage(),
      productsVm.loadFirstPage(),
    ]);

    if (nothingFound) {
      return AppRefreshIndicator(
        onRefresh: refresh,
        child: NoResultsWidget(
          isScrollable: true,
          emptyMessage: LangKeys.noSearchMatchesKey.tr(),
        ),
      );
    }

    final double spacing = MediaQuery.sizeOf(context).width * 0.03;

    return AppRefreshIndicator(
      onRefresh: refresh,
      child: PaginationScrollListener(
        canLoadNextPage: products.canRequestNextPage,
        onLoadNextPage: productsVm.loadNextPage,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(child: _SearchStoresStrip(args: storesArgs)),
            if (products.hasLoadedPage && !products.isEmpty)
              SliverToBoxAdapter(
                child: _SectionTitle(LangKeys.productsKey.tr()),
              ),
            PaginatedView<ProductModel>(
              provider: getProductsProvider(searchTerm),
              onRefresh: productsVm.loadFirstPage,
              onLoadNextPage: productsVm.loadNextPage,
              asSliver: true,
              emptyBuilder: (BuildContext context) => const SizedBox.shrink(),
              layout: PaginatedGridLayout(
                padding: const EdgeInsets.all(2),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 0.7,
                ),
              ),
              nextPagePlaceholdersCount: 2,
              placeholderBuilder: (BuildContext context) =>
                  const AppShimmer(child: ProductItem3View()),
              itemBuilder:
                  (BuildContext context, ProductModel product, int index) =>
                      ProductItem3View(
                        product: product,
                        onFavouriteChanged: (bool isFavourite) => productsVm
                            .updateProductFavourite(product.id, isFavourite),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The stores matching the term, side by side. Takes no room when none match
/// or their request failed — the products below still answer the search.
class _SearchStoresStrip extends ConsumerWidget {
  const _SearchStoresStrip({required this.args});

  final AllStoresArgs args;

  static const double _separator = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaginationStatus<StoreModel> status =
        PaginationStatus<StoreModel>.from(
          ref.watch(getAllStoresProvider(args)),
        );
    final GetAllStoresViewModel viewModel = ref.read(
      getAllStoresProvider(args).notifier,
    );

    final bool loading = !status.hasLoadedPage && status.firstPageError == null;
    if (!loading && status.items.isEmpty) return const SizedBox.shrink();

    final int trailing = status.isNextPageLoading ? 1 : 0;
    final int itemCount = loading ? 2 : status.items.length + trailing;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // One card and a peek of the next, so the strip reads as scrollable.
        final double cardWidth = constraints.maxWidth * 0.85;
        final double height = HomeStoresListView.itemHeight(cardWidth);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionTitle(LangKeys.storesKey.tr()),
            SizedBox(
              height: height,
              child: PaginationScrollListener(
                canLoadNextPage: status.canRequestNextPage,
                onLoadNextPage: viewModel.loadNextPage,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: itemCount,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(width: _separator),
                  itemBuilder: (BuildContext context, int index) {
                    final StoreModel? store = loading
                        ? null
                        : status.items.elementAtOrNull(index);
                    return SizedBox(
                      width: cardWidth,
                      child: store == null
                          ? const AppShimmer(child: StoreCardView())
                          : StoreCardView(
                              store: store,
                              onFavouriteChanged: (bool isFavourite) =>
                                  viewModel.updateStoreFavourite(
                                    store.id,
                                    isFavourite,
                                  ),
                            ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.style18SemiBold.copyWith(color: colors.black),
      ),
    );
  }
}
