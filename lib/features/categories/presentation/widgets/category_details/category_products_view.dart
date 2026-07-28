import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/next_page_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_item_card2.dart';

class CategoryProductsView extends ConsumerStatefulWidget {
  const CategoryProductsView({super.key, this.subCategory});
  final CategoryModel? subCategory;

  @override
  ConsumerState<CategoryProductsView> createState() =>
      _CategoryProductsViewState();
}

class _CategoryProductsViewState extends ConsumerState<CategoryProductsView> {
  /// How far from the end of the grid the next page starts loading, so it is
  /// already on its way by the time the user reaches the bottom.
  static const double _nextPageThreshold = 200;

  /// How many shimmer cards trail the grid while the next page loads.
  static const int _loadingCardsCount = 4;

  late final GetCategoryProductsViewModel productsViewModel;
  @override
  void initState() {
    super.initState();
    productsViewModel = ref.read(getCategoryProductsProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategoryProducts();
    });
  }

  void _fetchCategoryProducts() {
    productsViewModel.getCategoryProducts(
      categorySlug: ref.read(categoryProvider).slug ?? '',
      categoryId: widget.subCategory?.id,
    );
  }

  /// Reads the same parameters as [_fetchCategoryProducts], so the retry
  /// affordance in the grid footer reuses it as-is.
  ///
  /// The view model decides whether the request actually goes out: it skips when
  /// the server said there is nothing more to fetch and when another page is
  /// already in flight, so calling this on every scroll frame is harmless.
  void _fetchNextCategoryProducts() {
    productsViewModel.getNextCategoryProducts(
      categorySlug: ref.read(categoryProvider).slug ?? '',
      categoryId: widget.subCategory?.id,
    );
  }

  bool _onGridScroll(ScrollNotification notification) {
    // Ignore notifications bubbling up from nested scrollables.
    if (notification.depth != 0) return false;

    // A failed page waits for the retry tap instead of firing again on scroll.
    final productsState = ref.read(getCategoryProductsProvider);
    if (productsState.hasError && !productsState.isLoading) return false;

    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= 0) return false;
    if (metrics.pixels < metrics.maxScrollExtent - _nextPageThreshold) {
      return false;
    }

    _fetchNextCategoryProducts();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Surface a next-page failure as a snackbar the moment state turns to error
    // while products are already on screen. The full-screen error widget covers
    // the first-page failure, so that case (no previous value) is skipped.
    ref.listen(getCategoryProductsProvider, (previous, next) {
      // A settled error that just resolved from an in-flight request. Keying off
      // "previous was loading" (rather than "was not already error") is what
      // lets a second, third… retry failure surface again — after a retry the
      // error still lingers in state under the loading flag, so a "was error"
      // guard would swallow every failure after the first.
      final bool settledError = next.hasError && !next.isLoading;
      final bool cameFromLoading = previous?.isLoading == true;
      if (settledError && cameFromLoading && next.valueOrNull != null) {
        ErrorSnackBar.show(context, next.error.toString());
      }
    });

    final productsState = ref.watch(getCategoryProductsProvider);
    final PaginationModel<ProductModel>? pagination = productsState.valueOrNull;

    // Nothing loaded yet, so loading and error own the whole view.
    if (pagination == null) {
      if (productsState.hasError) {
        return ServerConnectionErrorWidget(
          message: productsState.error.toString(),
          onRetry: () => _fetchCategoryProducts(),
        );
      }
      return CategoryProductsViewShimmer();
    }

    final List<ProductModel> products = pagination.data;

    // A page is in flight, or the last one failed. Checked in this order because
    // a retry leaves the previous error in state while it loads.
    final bool isLoadingNextPage = productsState.isLoading;
    final bool nextPageFailed = !isLoadingNextPage && productsState.hasError;

    // Shimmer cards trail the grid while the next page loads.
    final int trailingCount = isLoadingNextPage ? _loadingCardsCount : 0;

    return AppRefreshIndicator(
      onRefresh: () async => _fetchCategoryProducts(),
      child: products.isEmpty
          ? NoItemsWidget(isScrollable: true)
          : NotificationListener<ScrollNotification>(
              onNotification: _onGridScroll,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(4),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: products.length + trailingCount,
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= products.length) {
                          return AppShimmer(
                            child: ProductItemCard2(onTap: () {}),
                          );
                        }
                        return ProductItemCard2(
                          productModel: products.elementAtOrNull(index),
                        );
                      },
                    ),
                  ),
                  // A full-width footer at the end of the list: it scrolls into
                  // view when the user reaches the bottom, rather than sitting
                  // pinned over the grid.
                  if (nextPageFailed)
                    SliverToBoxAdapter(
                      child: NextPageErrorWidget(
                        onRetry: () => _fetchNextCategoryProducts(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
