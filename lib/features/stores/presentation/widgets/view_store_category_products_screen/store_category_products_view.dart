import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/view_store_category_products/store_category_provider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/view_store_category_products/store_id_provider.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_store_category_products_vm.dart';

class StoreCategoryProductsView extends ConsumerStatefulWidget {
  const StoreCategoryProductsView({super.key});

  @override
  ConsumerState<StoreCategoryProductsView> createState() =>
      _StoreCategoryProductsViewState();
}

class _StoreCategoryProductsViewState
    extends ConsumerState<StoreCategoryProductsView> {
  late final GetStoreCategoryProductsViewModel productsViewModel;

  @override
  void initState() {
    super.initState();
    productsViewModel = ref.read(getStoreCategoryProductsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStoreCategoryProducts();
    });
  }

  void _fetchStoreCategoryProducts() {
    final CategoryModel category = ref.read(storeCategoryProvider);
    final int storeId = ref.read(storeIdProvider);
    productsViewModel.getStoreCategoryProducts(
      storeId: storeId,
      categoryId: category.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(getStoreCategoryProductsProvider);
    return productsState.when(
      loading: () => CategoryProductsViewShimmer(),
      error: (Object error, StackTrace stackTrace) =>
          ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: () => _fetchStoreCategoryProducts(),
          ),
      data: (List<ProductModel> products) => products.isEmpty
          ? NoItemsWidget()
          : GridView.builder(
              padding: EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) =>
                  ProductItemCard2(
                productModel: products.elementAtOrNull(index),
              ),
            ),
    );
  }
}
