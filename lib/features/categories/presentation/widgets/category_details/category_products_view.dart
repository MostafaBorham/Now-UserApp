import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';

class CategoryProductsView extends ConsumerStatefulWidget {
  const CategoryProductsView({
    super.key, this.subCategory,
  });
  final CategoryModel? subCategory;

  @override
  ConsumerState<CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends ConsumerState<CategoryProductsView> {
  late final GetCategoryProductsViewModel productsViewModel ;
  @override
  void initState() {
    super.initState();
    productsViewModel = ref.read(getCategoryProductsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategoryProducts();
    },);

  }

  void _fetchCategoryProducts(){
    productsViewModel.getCategoryProducts(categorySlug: ref.read(categoryProvider).slug??'',categoryId: widget.subCategory?.id);
  }
  @override
  Widget build(BuildContext context,) {
    final productsState = ref.watch(getCategoryProductsProvider);
    return productsState.when(
      loading: () => CategoryProductsViewShimmer(),
      error: (Object error, StackTrace stackTrace) =>
          ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: () => _fetchCategoryProducts(),
          ),
      data: (pagination) {
        final products = pagination.data;
        return AppRefreshIndicator(
          onRefresh: () async => _fetchCategoryProducts(),
          child: products.isEmpty? NoItemsWidget():GridView.builder(
            padding: EdgeInsets.all(4),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              // return Container(color: colors.error);
              return ProductItemCard2(
                productModel: products.elementAtOrNull(index),
              );
            },
          ),
        );
      },
    );
  }
}