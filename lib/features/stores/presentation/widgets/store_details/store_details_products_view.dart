import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card1.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_category_products_vm.dart';











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
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.6,
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




      enablePullToRefresh: false,
      layout: const PaginatedGridLayout(
        gridDelegate: _gridDelegate,
        padding: EdgeInsets.symmetric(vertical: 5),
      ),


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
