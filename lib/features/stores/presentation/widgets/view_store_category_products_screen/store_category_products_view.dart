import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card2.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/view_store_category_products/store_category_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/view_store_category_products/store_id_provider.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_category_products_vm.dart';

/// The products of the opened store category as an infinite-scrolling grid.
///
/// Only describes *what* the grid shows — the paging behaviour (next page on
/// scroll, pull-to-refresh, loading, empty and error states) lives in
/// [PaginatedView] and [GetStoreCategoryProductsViewModel]. The first page loads
/// automatically the first time this category's provider is watched.
class StoreCategoryProductsView extends ConsumerWidget {
  const StoreCategoryProductsView({super.key});

  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CategoryModel category = ref.read(storeCategoryProvider);
    final int storeId = ref.read(storeIdProvider);
    final StoreCategoryProductsArgs args = (
      storeId: storeId,
      categoryId: category.id,
      filter: ProductFilters.all,
    );
    final GetStoreCategoryProductsViewModel viewModel = ref.read(
      getStoreCategoryProductsProvider(args).notifier,
    );

    return PaginatedView<ProductModel>(
      provider: getStoreCategoryProductsProvider(args),
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
      layout: const PaginatedGridLayout(
        gridDelegate: _gridDelegate,
        padding: EdgeInsets.all(4),
      ),
      // Fills the grid while the first page loads and trails it while the next
      // one does, so the skeleton always matches the real cards.
      placeholderBuilder: (BuildContext context) =>
          AppShimmer(child: ProductItemCard2(onTap: () {})),
      itemBuilder: (BuildContext context, ProductModel product, int index) =>
          ProductItemCard2(
            productModel: product,
            onFavouriteChanged: (bool isFavourite) =>
                viewModel.updateProductFavourite(product.id, isFavourite),
          ),
    );
  }
}
