import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';







typedef CategoryProductsArgs = ({
  String categorySlug,
  int? categoryId,
  String? searchKey,
});










final getCategoryProductsProvider = StateNotifierProvider.autoDispose.family<
    GetCategoryProductsViewModel,
    AsyncValue<PaginationModel<ProductModel>>,
    CategoryProductsArgs>(
  (Ref ref, CategoryProductsArgs args) =>
      GetCategoryProductsViewModel(args: args)..getProducts(),
);






class GetCategoryProductsViewModel
    extends StateNotifier<AsyncValue<PaginationModel<ProductModel>>> {
  GetCategoryProductsViewModel({required this.args})
      : super(const AsyncValue<PaginationModel<ProductModel>>.loading());

  final CategoriesRepo _repo = CategoriesRepo();



  final CategoryProductsArgs args;




  final ValueNotifier<AsyncValue<bool>> loadMoreState =
      ValueNotifier<AsyncValue<bool>>(const AsyncValue<bool>.data(true));



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

        state = AsyncValue<PaginationModel<ProductModel>>.data(
          currentPage.appendPage(newPage),
        );
        loadMoreState.value = AsyncValue<bool>.data(newPage.hasMore);
      },
    );
  }






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
