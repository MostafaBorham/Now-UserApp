import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class CategoryProductsView extends ConsumerStatefulWidget {
  const CategoryProductsView({
    super.key,
    required this.sortType,
  });
  final StoresSortType sortType;

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

  // TODO: forward widget.sortType to the API once the products sort param is wired.
  late final CategoryProductsArgs _args = (
    categorySlug: ref.read(categoryProvider).slug ?? '',
    categoryId: null,
    searchKey: null,
  );

  @override
  Widget build(BuildContext context) {
    final GetCategoryProductsViewModel productsViewModel = ref.read(
      getCategoryProductsProvider(_args).notifier,
    );
    return PaginatedView<ProductModel>(
      provider: getCategoryProductsProvider(_args),
      onRefresh: productsViewModel.loadFirstPage,
      onLoadNextPage: productsViewModel.loadNextPage,
      layout: const PaginatedGridLayout(
        gridDelegate: _gridDelegate,
        padding: EdgeInsets.all(4),
      ),
      placeholderBuilder: (BuildContext context) =>
          AppShimmer(child: ProductItem3View()),
      itemBuilder: (BuildContext context, ProductModel product, int index) =>
          ProductItem3View(),
    );
  }
}
