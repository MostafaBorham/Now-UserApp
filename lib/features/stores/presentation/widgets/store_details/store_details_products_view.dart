import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_category_products_vm.dart';

/// One store details filter tab: the store's products for [filter] as an
/// infinite-scrolling grid.
///
/// Each filter is its own [getStoreCategoryProductsProvider] family member, so
/// switching tabs shows that filter's own products and pages them independently.
/// The paging behaviour (next page on scroll, loading, empty and error states)
/// lives in [PaginatedView] and [GetStoreCategoryProductsViewModel]; the first
/// page loads automatically the first time this filter's provider is watched.
/// Pull-to-refresh is disabled here — the store details screen owns the top-of-
/// page pull that reloads the whole store.
class StoreDetailsProductsView extends ConsumerWidget {
  const StoreDetailsProductsView({
    super.key,
    required this.storeId,
    required this.filter,
  });

  final int storeId;
  final ProductFilters filter;

  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 16,
        // Design card: 170 x 280.
        childAspectRatio: 170 / 280,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StoreCategoryProductsArgs args = (
      storeId: storeId,
      categoryId: null,
      filter: filter,
    );
    final GetStoreCategoryProductsViewModel viewModel = ref.read(
      getStoreCategoryProductsProvider(args).notifier,
    );

    return PaginatedView<ProductModel>(
      provider: getStoreCategoryProductsProvider(args),
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
      // The store details screen owns pull-to-refresh: a pull at the top of the
      // page reloads the store via getStoreDetails. The product grid under the
      // tabs paginates on scroll but has no refresh of its own, so the two
      // gestures don't fight inside the NestedScrollView.
      enablePullToRefresh: false,
      layout: const PaginatedGridLayout(
        gridDelegate: _gridDelegate,
        padding: EdgeInsets.symmetric(vertical: 5),
      ),
      // Fills the grid while the first page loads and trails it while the next
      // one does, so the skeleton always matches the real cards.
      placeholderBuilder: (BuildContext context) =>
          const AppShimmer(child: ProductItemCard1()),
      itemBuilder: (BuildContext context, ProductModel product, int index) =>
          ProductItemCard1(
            product: product,
            onFavouriteChanged: (bool isFavourite) =>
                viewModel.updateProductFavourite(product.id, isFavourite),
          ),
    );
  }
}
