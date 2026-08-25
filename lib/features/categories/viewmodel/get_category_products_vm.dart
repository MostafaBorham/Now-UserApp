import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// The query one [GetCategoryProductsViewModel] pages through: a category's
/// [categorySlug], optionally narrowed to the sub-category [categoryId] and to a
/// [searchKey] text filter. Used as the [getCategoryProductsProvider] family key,
/// so each distinct query keeps its own independent pagination state (e.g. every
/// product tab on the category details screen, or the same tab with vs. without a
/// search term).
typedef CategoryProductsArgs = ({
  String categorySlug,
  int? categoryId,
  String? searchKey,
});

/// Single task: page through the products of a category for the category
/// details screen.
///
/// A `family` keyed by [CategoryProductsArgs]: each query gets its own view model
/// and state, so several tabs paging different queries at once never share (or
/// clobber) each other's products. The first page starts as soon as an arg is
/// first watched; [GetCategoryProductsViewModel.loadMore] and
/// [GetCategoryProductsViewModel.getProducts] (refresh / retry) then replay the
/// same query.
final getCategoryProductsProvider = StateNotifierProvider.autoDispose.family<
    GetCategoryProductsViewModel,
    AsyncValue<PaginationModel<ProductModel>>,
    CategoryProductsArgs>(
  (Ref ref, CategoryProductsArgs args) =>
      GetCategoryProductsViewModel(args: args)..getProducts(),
);

/// Pages through a category's products, keeping the loaded list ([state]) and
/// the "loading another page" signal ([loadMoreState]) apart: the list state
/// drives the first-load shimmer, empty and error views, while [loadMoreState]
/// drives only the trailing shimmer / next-page error — so appending a page
/// never flips the whole view back to loading.
class GetCategoryProductsViewModel
    extends StateNotifier<AsyncValue<PaginationModel<ProductModel>>> {
  GetCategoryProductsViewModel({required this.args})
      : super(const AsyncValue<PaginationModel<ProductModel>>.loading());

  final CategoriesRepo _repo = CategoriesRepo();

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same products.
  final CategoryProductsArgs args;

  /// Whether the next page is in flight / failed, held apart from [state] so the
  /// visible list is never disturbed while a further page loads. `data(true)`
  /// until the first page settles, then tracks `hasMore`.
  final ValueNotifier<AsyncValue<bool>> loadMoreState =
      ValueNotifier<AsyncValue<bool>>(const AsyncValue<bool>.data(true));

  /// Loads (or reloads) the first page, dropping whatever was loaded before —
  /// the initial fetch, pull-to-refresh, and retrying a failed first page.
  Future<void> getProducts() async {
    state = const AsyncValue<PaginationModel<ProductModel>>.loading();

    final Either<Failure, PaginationModel<ProductModel>> result =
        await _fetchPage(1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        state = AsyncValue<PaginationModel<ProductModel>>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<ProductModel> firstPage) {
        state = AsyncValue<PaginationModel<ProductModel>>.data(firstPage);
        loadMoreState.value = AsyncValue<bool>.data(firstPage.hasMore);
      },
    );
  }

  /// Loads the page after the one in state and appends it to the visible list.
  /// A no-op when nothing is loaded yet, the server has no more pages, or a
  /// page is already in flight — so it is safe to call from a scroll listener.
  Future<void> loadMore() async {
    final PaginationModel<ProductModel>? currentPage = state.valueOrNull;

    if (currentPage == null ||
        !currentPage.hasMore ||
        loadMoreState.value.isLoading) {
      return;
    }

    loadMoreState.value = const AsyncValue<bool>.loading();

    final Either<Failure, PaginationModel<ProductModel>> result =
        await _fetchPage(currentPage.currentPage + 1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        loadMoreState.value = AsyncValue<bool>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<ProductModel> newPage) {
        // Append the freshly fetched page to the visible list.
        state = AsyncValue<PaginationModel<ProductModel>>.data(
          currentPage.appendPage(newPage),
        );
        loadMoreState.value = AsyncValue<bool>.data(newPage.hasMore);
      },
    );
  }

  /// Flips [ProductModel.isFavorite] on the single loaded product with [productId]
  /// in place, leaving the rest of the list (and its scroll position) untouched.
  /// Called when the favourite icon on a card reports a settled change, so a
  /// card scrolled off and back keeps the new status instead of reverting to the
  /// server-loaded one.
  void updateProductFavourite(int? productId, bool isFavourite) {
    final PaginationModel<ProductModel>? currentPage = state.valueOrNull;
    if (currentPage == null || productId == null) return;

    final List<ProductModel> updated = <ProductModel>[
      for (final ProductModel product in currentPage.data)
        product.id == productId
            ? product.copyWith(isFavorite: isFavourite)
            : product,
    ];

    state = AsyncValue<PaginationModel<ProductModel>>.data(
      currentPage.copyWithData(updated),
    );
  }

  Future<Either<Failure, PaginationModel<ProductModel>>> _fetchPage(int page) {
    return _repo.getCategoryProducts(
      categorySlug: args.categorySlug,
      categoryId: args.categoryId,
      page: page,
      search: args.searchKey,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    loadMoreState.dispose();
    super.dispose();
  }
}
