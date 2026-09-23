import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_products_vm.dart';

/// The results for [searchTerm] as an infinite-scrolling grid. Paging, pull to
/// refresh, the empty state and the retry on a failed first page all come from
/// [PaginatedView].
class SearchProductsGrid extends ConsumerWidget {
  const SearchProductsGrid({super.key, required this.searchTerm});

  final String searchTerm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GetProductsViewModel viewModel = ref.read(
      getProductsProvider(searchTerm).notifier,
    );
    final double spacing = MediaQuery.sizeOf(context).width * 0.03;

    return PaginatedView<ProductModel>(
      provider: getProductsProvider(searchTerm),
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
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
      itemBuilder: (BuildContext context, ProductModel product, int index) =>
          ProductItem3View(
            product: product,
            onFavouriteChanged: (bool isFavourite) =>
                viewModel.updateProductFavourite(product.id, isFavourite),
          ),
    );
  }
}
