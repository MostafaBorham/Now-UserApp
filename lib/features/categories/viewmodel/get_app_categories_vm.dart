import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: page through the app categories for the categories screen.
///
/// The query takes no parameters, so the first page starts as soon as the
/// provider is first watched — screens only `ref.watch(getAppCategoriesProvider)`
/// and render the pagination state. `loadNextPage()` and `loadFirstPage()`
/// (refresh / retry) come from [PaginatedViewModel].
final getAppCategoriesProvider =
    StateNotifierProvider.autoDispose<GetAppCategoriesViewModel,
        AsyncValue<PaginationModel<CategoryModel>>>(
  (Ref ref) => GetAppCategoriesViewModel()..loadFirstPage(),
);

class GetAppCategoriesViewModel extends PaginatedViewModel<CategoryModel> {
  final CategoriesRepo _repo = CategoriesRepo();

  @override
  Future<Either<Failure, PaginationModel<CategoryModel>>> fetchPage(int page) {
    return _repo.getAppCategories(page: page);
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
