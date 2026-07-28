import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: fetch the categories list for the categories screen.
///
/// The fetch starts as soon as the provider is first watched, so screens only
/// need to `ref.watch(getCategoriesProvider)` and render the [AsyncValue].
/// Retry with `ref.read(getCategoriesProvider.notifier).getCategories()`.
final getCategoryProductsProvider =
    StateNotifierProvider.autoDispose<GetCategoryProductsViewModel,
        AsyncValue<PaginationModel<ProductModel>>>(
  (Ref ref) =>
      GetCategoryProductsViewModel(const AsyncValue.loading()),
);

/*final filterCategoryProductsProvider =
StateNotifierProvider.autoDispose.family<
    GetCategoryProductsViewModel,
    AsyncValue<List<ProductModel>>,
    int?>(
      (ref, categoryId) {
    return GetCategoryProductsViewModel(
      const AsyncValue.loading(),
    );
  },
);*/

class GetCategoryProductsViewModel
    extends StateNotifier<AsyncValue<PaginationModel<ProductModel>>> {
  GetCategoryProductsViewModel(super.initialState);

  final CategoriesRepo _repo = CategoriesRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getCategoryProducts({required String categorySlug,required int? categoryId}) async {
    state = const AsyncValue.loading();

    final result = await _repo.getCategoryProducts(categorySlug: categorySlug,categoryId: categoryId,page: 1);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) {
        print('=== fail');
        return AsyncValue.error(failure.message, StackTrace.current);
      },
      (products) {
        return AsyncValue.data(products);
      },
    );
  }

  /// Fetches the page after the one currently in state and appends it to the
  /// list already there.
  ///
  /// Unlike [getCategoryProducts] this keeps the loaded products in state while
  /// the request is in flight — the state is loading *and* still carries its
  /// value — so the screen can go on showing the grid and mark the new page as
  /// pending underneath it. A failure works the same way: the error lands in
  /// state without dropping the products.
  ///
  /// Does nothing when there is no page loaded yet, when the server said there
  /// is nothing more to fetch, or while another page is already on its way.
  Future<void> getNextCategoryProducts({required String categorySlug,required int? categoryId}) async {
    final PaginationModel<ProductModel>? currentPage = state.valueOrNull;
    if (currentPage == null || !currentPage.hasMore || state.isLoading) return;

    state = const AsyncValue<PaginationModel<ProductModel>>.loading()
        .copyWithPrevious(state);

    final result = await _repo.getCategoryProducts(
      categorySlug: categorySlug,
      categoryId: categoryId,
      page: currentPage.currentPage + 1,
    );

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue<PaginationModel<ProductModel>>.error(
            failure.message,
            StackTrace.current,
          ).copyWithPrevious(state),
      (PaginationModel<ProductModel> nextPage) =>
          AsyncValue.data(currentPage.appendPage(nextPage)),
    );
  }
}
