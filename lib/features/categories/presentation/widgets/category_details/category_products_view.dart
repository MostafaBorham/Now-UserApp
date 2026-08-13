import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card2.dart';

/// The products of the opened category as an infinite-scrolling grid.
///
/// Only describes *what* the grid shows — the paging behaviour (next page on
/// scroll, pull-to-refresh, loading, empty and error states) lives in
/// [PaginatedView] and [GetCategoryProductsViewModel].
class CategoryProductsView extends ConsumerStatefulWidget {
  const CategoryProductsView({super.key});

  @override
  ConsumerState<CategoryProductsView> createState() =>
      _CategoryProductsViewState();
}

class _CategoryProductsViewState extends ConsumerState<CategoryProductsView> {
  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      );

  late final GetCategoryProductsViewModel _productsViewModel;

  @override
  void initState() {
    super.initState();
    _productsViewModel = ref.read(getCategoryProductsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProducts());
  }

  /// Loads the first page of the opened category. Also the pull-to-refresh and
  /// first-page retry action, so all three ask for the same query.
  Future<void> _fetchProducts() {
    return _productsViewModel.getCategoryProducts(
      categorySlug: ref.read(categoryProvider).slug ?? '',
      categoryId: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedView<ProductModel>(
      provider: getCategoryProductsProvider,
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
