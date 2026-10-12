import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_category_products_vm.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:easy_localization/easy_localization.dart';

/// One store details filter tab: the store's products for [filter] as a grid
/// sliver in the store page's single scroll view.
///
/// Each filter is its own [getStoreCategoryProductsProvider] family member, so
/// switching tabs shows that filter's own products and pages them independently.
/// The loading, empty and error states live in [PaginatedView] and
/// [GetStoreCategoryProductsViewModel]; the first page loads automatically the
/// first time this filter's provider is watched. Paging and pull-to-refresh
/// belong to the store details screen, which owns the scroll view.
class StoreDetailsProductsView extends ConsumerWidget {
  const StoreDetailsProductsView({
    super.key,
    required this.storeId,
    required this.filter,
  });

  final int storeId;
  final ProductFilters filter;

  /// No category and no search: the whole store under one filter tab. The
  /// category chips open their own screen, which reuses the provider with a
  /// categoryId set.
  static StoreCategoryProductsArgs argsFor(
    int storeId,
    ProductFilters filter,
  ) => (storeId: storeId, categoryId: null, filter: filter, searchKey: null);

  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.6,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StoreCategoryProductsArgs args = argsFor(storeId, filter);
    final GetStoreCategoryProductsViewModel viewModel = ref.read(
      getStoreCategoryProductsProvider(args).notifier,
    );

    return PaginatedView<ProductModel>(
      provider: getStoreCategoryProductsProvider(args),
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
      // A sliver under the store header and the pinned tabs, so the page ends
      // at the last product (BUG-017). The screen pages it from its own scroll
      // and owns the pull that reloads the whole store.
      asSliver: true,
      layout: const PaginatedGridLayout(
        gridDelegate: _gridDelegate,
        padding: EdgeInsets.symmetric(vertical: 5),
      ),
      // Fills the grid while the first page loads and trails it while the next
      // one does, so the skeleton always matches the real cards.
      placeholderBuilder: (BuildContext context) =>
          const AppShimmer(child: ProductItemCard1()),
      // Near the top of the grid: centred, it landed at the bottom of the
      // screen, under the tall store header.
      emptyBuilder: (BuildContext context) => NoResultsWidget(
        alignTop: true,
        emptyMessage: (filter == ProductFilters.offer
                ? LangKeys.noOffersNowKey
                : LangKeys.noProductsYetKey)
            .tr(),
      ),
      itemBuilder: (BuildContext context, ProductModel product, int index) =>
          ProductItemCard1(
            product: product,
            onFavouriteChanged: (bool isFavourite) =>
                viewModel.updateProductFavourite(product.id, isFavourite),
          ),
    );
  }
}
