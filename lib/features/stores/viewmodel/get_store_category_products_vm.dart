import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

/// Single task: page through the products of one store category for the
/// view-store-category-products screen.
///
/// The screen starts the first fetch with [getStoreCategoryProducts] — it is
/// the only call that needs the query parameters (it owns the store id and
/// category id) — then `loadNextPage()` and `loadFirstPage()` (refresh / retry)
/// replay them from [PaginatedViewModel].
final getStoreCategoryProductsProvider = StateNotifierProvider.autoDispose<
    GetStoreCategoryProductsViewModel,
    AsyncValue<PaginationModel<ProductModel>>>(
  (Ref ref) => GetStoreCategoryProductsViewModel(),
);

class GetStoreCategoryProductsViewModel
    extends PaginatedViewModel<ProductModel> {
  final StoresRepo _repo = StoresRepo();

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same products.
  int _storeId = 0;
  int? _categoryId;

  /// Loads the first page of [categoryId] within [storeId]. Call again with
  /// different arguments to switch the query — the pages already loaded are
  /// dropped.
  Future<void> getStoreCategoryProducts({
    required int storeId,
    required int? categoryId,
  }) {
    _storeId = storeId;
    _categoryId = categoryId;
    return loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) {
    return _repo.getStoreCategoryProducts(
      storeId: _storeId,
      categoryId: _categoryId,
      page: page,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
