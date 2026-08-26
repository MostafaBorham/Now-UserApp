import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_products_search_provider.dart';
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

  /// The view model for the query currently on screen. Re-bound in [build]
  /// because changing the search term switches to a different family member
  /// (and so a different view model instance).
  GetCategoryProductsViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _viewModel?.loadMoreState.removeListener(_onLoadMoreStateChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onLoadMoreStateChanged() {
    final AsyncValue<bool>? loadMoreState = _viewModel?.loadMoreState.value;
    if (loadMoreState != null && loadMoreState.hasError && mounted) {
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
      _viewModel?.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to the debounced search term: each distinct query is its own family
    // member with independent pagination state.
    final String search = ref.watch(categoryProductsSearchProvider);
    final CategoryProductsArgs args = (
      categorySlug: ref.read(categoryProvider).slug ?? '',
      categoryId: null,
      searchKey: search.isEmpty ? null : search,
    );

    // Re-bind to the current query's view model and move the load-more error
    // listener onto it whenever the query (and so the instance) changes.
    final GetCategoryProductsViewModel viewModel =
        ref.read(getCategoryProductsProvider(args).notifier);
    if (!identical(viewModel, _viewModel)) {
      _viewModel?.loadMoreState.removeListener(_onLoadMoreStateChanged);
      _viewModel = viewModel
        ..loadMoreState.addListener(_onLoadMoreStateChanged);
    }

    // Watch only the coarse view shape — loading / error / item count — not the
    // products themselves. A favourite toggle changes an item in place without
    // touching any of these, so this widget (and with it the whole grid) does
    // not rebuild; only the one item watching that product does (see
    // [_CategoryProductGridItem]).
    final ({bool isLoading, String? error, int length}) view = ref.watch(
      getCategoryProductsProvider(args).select(
        (AsyncValue<PaginationModel<ProductModel>> state) => (
          isLoading: state.isLoading,
          error: state.hasError ? state.error.toString() : null,
          length: state.valueOrNull?.data.length ?? 0,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, con) {
        if (view.isLoading) return const CategoryProductsViewShimmer();
        if (view.error != null) {
          return ServerConnectionErrorWidget(
            message: view.error!,
            onRetry: viewModel.getProducts,
          );
        }

        return AppRefreshIndicator(
          onRefresh: viewModel.getProducts,
          child: view.length == 0
              ? const NoResultsWidget(isScrollable: true)
              : ValueListenableBuilder<AsyncValue<bool>>(
                  valueListenable: viewModel.loadMoreState,
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
                          itemCount: view.length + loadingItemsCount,
                          itemBuilder: (BuildContext context, int index) {
                            if (index >= view.length) {
                              return const AppShimmer(
                                child: ProductItem3View(),
                              );
                            }
                            return _CategoryProductGridItem(
                              args: args,
                              index: index,
                            );
                          },
                        );
                      },
                ),
        );
      },
    );
  }
}

/// A single product cell that watches **only its own product** in the paginated
/// state. Because [GetCategoryProductsViewModel.updateProductFavourite] rewrites
/// just the toggled product (every other item keeps its identity), `select`'s
/// `==` check lets exactly this cell rebuild when its favourite flips — the rest
/// of the grid is untouched.
class _CategoryProductGridItem extends ConsumerWidget {
  const _CategoryProductGridItem({required this.args, required this.index});

  final CategoryProductsArgs args;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProductModel? product = ref.watch(
      getCategoryProductsProvider(args).select(
        (AsyncValue<PaginationModel<ProductModel>> state) =>
            state.valueOrNull?.data.elementAtOrNull(index),
      ),
    );

    if (product == null) return const SizedBox.shrink();

    return ProductItem3View(
      product: product,
      onFavouriteChanged: (bool isFavourite) => ref
          .read(getCategoryProductsProvider(args).notifier)
          .updateProductFavourite(product.id, isFavourite),
    );
  }
}
