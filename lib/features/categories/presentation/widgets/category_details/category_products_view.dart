import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class CategoryProductsView extends ConsumerStatefulWidget {
  const CategoryProductsView({super.key, required this.sortType});
  final StoresSortType sortType;

  @override
  ConsumerState<CategoryProductsView> createState() =>
      _CategoryProductsViewState();
}

class _CategoryProductsViewState extends ConsumerState<CategoryProductsView> {

  final ScrollController _scrollController = ScrollController();
  late final GetCategoryProductsViewModel _viewModel;

  late final CategoryProductsArgs _args = (
    categorySlug: ref.read(categoryProvider).slug ?? '',
    categoryId: null,
    searchKey: null,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _viewModel = ref.read(getCategoryProductsProvider(_args).notifier);
    _viewModel.loadMoreState.addListener(_onLoadMoreStateChanged);
  }

  @override
  void dispose() {
    _viewModel.loadMoreState.removeListener(_onLoadMoreStateChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onLoadMoreStateChanged() {
    final AsyncValue<bool> loadMoreState = _viewModel.loadMoreState.value;
    if (loadMoreState.hasError && mounted) {
      ErrorSnackBar.show(context, loadMoreState.error.toString());
    }
  }

  void _onScroll() {
    // Only load more once the very end of the grid is fully visible on screen.
    // `extentAfter` is the amount of scrollable content still hidden below the
    // viewport, so it reaches 0 exactly when no part of the grid tail is
    // clipped off-screen — unlike a fixed pixel threshold, which re-fires while
    // the user is still near (but not at) the bottom with the tail cut off.
    if (_scrollController.position.extentAfter <= 0) {
      _viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginationModel<ProductModel>> productsState = ref.watch(
      getCategoryProductsProvider(_args),
    );

    return LayoutBuilder(
      builder: (context,con) {
        return productsState.when(
          loading: () => const CategoryProductsViewShimmer(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: _viewModel.getProducts,
              ),
          data: (PaginationModel<ProductModel> products) {
            final List<ProductModel> items = products.data;

            return AppRefreshIndicator(
              onRefresh: _viewModel.getProducts,
              child: items.isEmpty
                  ? const NoItemsWidget(isScrollable: true)
                  : ValueListenableBuilder<AsyncValue<bool>>(
                      valueListenable: _viewModel.loadMoreState,
                      builder:
                          (
                            BuildContext context,
                            AsyncValue<bool> value,
                            Widget? child,
                          ) {
                            final int loadingItemsCount = value.isLoading ? 2 : 0;
                            return GridView.builder(
                              controller: _scrollController,
                              addRepaintBoundaries: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.all(2),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: con.maxWidth*0.03,
                                mainAxisSpacing: con.maxWidth*0.03,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: items.length + loadingItemsCount,
                              itemBuilder: (BuildContext context, int index) {
                                if (index >= items.length) {
                                  return const AppShimmer(
                                    child: ProductItem3View(),
                                  );
                                }
                                return const ProductItem3View();
                              },
                            );
                          },
                    ),
            );
          },
        );
      }
    );
  }
}
