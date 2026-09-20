import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';
import 'package:nowdelivery_user_app/features/products/viewmodel/get_products_vm.dart';

class SearchProductsGrid extends ConsumerWidget {
  const SearchProductsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProductModel>> state =
        ref.watch(getProductsProvider);
    final double spacing = MediaQuery.sizeOf(context).width * 0.03;
    final double stateHeight = MediaQuery.sizeOf(context).height * 0.4;

    final SliverGridDelegate gridDelegate =
        SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: 0.7,
    );

    return state.when(
      loading: () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(2),
        gridDelegate: gridDelegate,
        itemCount: 4,
        itemBuilder: (_, _) => const AppShimmer(child: ProductItem3View()),
      ),
      error: (Object error, _) => SizedBox(
        height: stateHeight,
        child: ServerConnectionErrorWidget(message: error.toString()),
      ),
      data: (List<ProductModel> products) => products.isEmpty
          ? SizedBox(height: stateHeight, child: const NoResultsWidget())
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(2),
              gridDelegate: gridDelegate,
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final ProductModel product = products[index];
                return ProductItem3View(
                  product: product,
                  onFavouriteChanged: (bool isFavourite) => ref
                      .read(getProductsProvider.notifier)
                      .updateProductFavourite(product.id, isFavourite),
                );
              },
            ),
    );
  }
}
