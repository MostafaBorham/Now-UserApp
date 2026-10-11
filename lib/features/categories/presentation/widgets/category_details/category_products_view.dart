import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_products_search_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_products_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_products_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:easy_localization/easy_localization.dart';

/// The products of the opened category as an infinite-scrolling grid.
///
/// Same shape as [CategoryStoresView] in the tab next to it: a manual
/// [ScrollController] drives next-page loading, and the coarse view shape
/// (first-load shimmer, empty, error, trailing next-page shimmer) is read off
/// the view model's paginated state via [PaginationStatus].
class CategoryProductsView extends ConsumerStatefulWidget {
  const CategoryProductsView({super.key});

  @override
  ConsumerState<CategoryProductsView> createState() =>
      _CategoryProductsViewState();
}

class _CategoryProductsViewState extends ConsumerState<CategoryProductsView> {
  final ScrollController _scrollController = ScrollController();

  /// The query currently on screen. Recomputed in [build] from the debounced
  /// search term, so [_onScroll] always pages the family member being shown.
  late CategoryProductsArgs _args;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // `loadNextPage` is a no-op unless another page may be requested, so
    // calling it on every frame the end of the grid is visible is safe.
    if (_scrollController.position.extentAfter <= 0) {
      ref.read(getCategoryProductsProvider(_args).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String search = ref.watch(categoryProductsSearchProvider);
    _args = (
      categorySlug: ref.read(categoryProvider).slug ?? '',
      categoryId: null,
      searchKey: search.isEmpty ? null : search,
    );

    final GetCategoryProductsViewModel viewModel =
        ref.read(getCategoryProductsProvider(_args).notifier);

    // Surface a failed next-page load without disturbing the grid.
    ref.listen<String?>(
      getCategoryProductsProvider(_args).select(
        (AsyncValue<PaginationModel<ProductModel>> state) =>
            PaginationStatus<ProductModel>.from(state).nextPageError,
      ),
      (String? previous, String? next) {
        if (next != null && mounted) AppToast.showError(context, next);
      },
    );

    // Watch only the coarse view shape, not the products themselves, so
    // appending a page rebuilds only the new cells.
    final ({
      bool isFirstPageLoading,
      String? firstPageError,
      bool isNextPageLoading,
      int length,
    }) view = ref.watch(
      getCategoryProductsProvider(_args).select(
        (AsyncValue<PaginationModel<ProductModel>> state) {
          final PaginationStatus<ProductModel> status =
              PaginationStatus<ProductModel>.from(state);
          return (
            isFirstPageLoading: status.isFirstPageLoading,
            firstPageError: status.firstPageError,
            isNextPageLoading: status.isNextPageLoading,
            length: status.items.length,
          );
        },
      ),
    );

    if (view.isFirstPageLoading) return const CategoryProductsViewShimmer();
    if (view.firstPageError != null) {
      return ServerConnectionErrorWidget(
        message: view.firstPageError!,
        onRetry: viewModel.loadFirstPage,
      );
    }

    final int loadingItemsCount = view.isNextPageLoading ? 2 : 0;

    return AppRefreshIndicator(
      onRefresh: viewModel.loadFirstPage,
      child: view.length == 0
          ? NoResultsWidget(
              isScrollable: true,
              alignTop: true,
              emptyMessage: (search.isEmpty
                      ? LangKeys.noProductsYetKey
                      : LangKeys.noSearchMatchesKey)
                  .tr(),
            )
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints con) =>
                  GridView.builder(
                    controller: _scrollController,
                    addRepaintBoundaries: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(2),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: con.maxWidth * 0.03,
                      mainAxisSpacing: con.maxWidth * 0.03,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: view.length + loadingItemsCount,
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= view.length) {
                        return const AppShimmer(child: ProductItem3View());
                      }
                      return _CategoryProductGridItem(
                        args: _args,
                        index: index,
                      );
                    },
                  ),
            ),
    );
  }
}

/// A single product cell that watches **only its own product** in the
/// paginated state, so the next page arriving leaves it untouched.
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
