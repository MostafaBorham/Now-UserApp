import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// [PaginatedView] and [GetStoreCategoryProductsViewModel].
class StoreCategoryProductsView extends ConsumerStatefulWidget {
  const StoreCategoryProductsView({super.key});

  @override
  ConsumerState<StoreCategoryProductsView> createState() =>
      _StoreCategoryProductsViewState();
}

class _StoreCategoryProductsViewState
    extends ConsumerState<StoreCategoryProductsView> {
  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      );

  late final GetStoreCategoryProductsViewModel _productsViewModel;

  @override
  void initState() {
    super.initState();
    _productsViewModel = ref.read(getStoreCategoryProductsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProducts());
  }

  /// Loads the first page of the opened store category. Also the pull-to-refresh
  /// and first-page retry action, so all three ask for the same query.
  Future<void> _fetchProducts() {
    final CategoryModel category = ref.read(storeCategoryProvider);
    final int storeId = ref.read(storeIdProvider);
    return _productsViewModel.getStoreCategoryProducts(
      storeId: storeId,
      categoryId: category.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedView<ProductModel>(
      provider: getStoreCategoryProductsProvider,
      onRefresh: _fetchProducts,
      onLoadNextPage: _productsViewModel.loadNextPage,
      layout: const PaginatedGridLayout(
        gridDelegate: _gridDelegate,
        padding: EdgeInsets.all(4),
      ),
      // Fills the grid while the first page loads and trails it while the next
      // one does, so the skeleton always matches the real cards.
      placeholderBuilder: (BuildContext context) =>
          AppShimmer(child: ProductItemCard2(onTap: () {})),
      itemBuilder: (BuildContext context, ProductModel product, int index) =>
          ProductItemCard2(productModel: product),
    );
  }
}
