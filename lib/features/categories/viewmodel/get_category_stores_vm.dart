import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: page through the stores of a category for the category
/// details screen.
///
/// The screen starts the first fetch with [getCategoryStores] — it is the only
/// call that needs the query parameters — then `loadNextPage()` and
/// `loadFirstPage()` (refresh / retry) replay them from [PaginatedViewModel].
final getCategoryStoresProvider =
    StateNotifierProvider.autoDispose<GetCategoryStoresViewModel,
        AsyncValue<PaginationModel<StoreModel>>>(
  (Ref ref) => GetCategoryStoresViewModel(),
);

class GetCategoryStoresViewModel extends PaginatedViewModel<StoreModel> {
  final CategoriesRepo _repo = CategoriesRepo();

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same stores.
  String _categorySlug = '';
  int? _categoryId;

  /// Loads the first page of [categorySlug], optionally narrowed to the
  /// sub-category [categoryId]. Call again with different arguments to switch
  /// the query — the pages already loaded are dropped.
  Future<void> getCategoryStores({
    required String categorySlug,
    required int? categoryId,
  }) {
    _categorySlug = categorySlug;
    _categoryId = categoryId;
    return loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) {
    return _repo.getCategoryStores(
      categorySlug: _categorySlug,
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
