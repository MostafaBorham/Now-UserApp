import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// Single task: page through the app categories.
///
/// Kept alive (not `autoDispose`) so the first page is preloaded once on the
/// splash screen and then reused — the home categories carousel and the
/// categories screen share the same fetched data instead of refetching. The
/// first page starts as soon as the provider is first read/watched, so screens
/// only `ref.watch(getAppCategoriesProvider)` and render the pagination state;
/// `loadNextPage()` and `loadFirstPage()` (refresh / retry) come from
/// [PaginatedViewModel]. A consumer opened while this shared state has no value
/// (never loaded, or errored) calls `loadFirstPage()` from its `initState` so
/// it flips to loading and shows its shimmer first; a loaded list is kept.
///
/// This is the unfiltered, app-wide list, shared by the home carousel, the
/// categories screen and the search screen's top-categories strip.
final getAppCategoriesProvider =
    StateNotifierProvider<
      GetAppCategoriesViewModel,
      AsyncValue<PaginationModel<CategoryModel>>
    >((Ref ref) => GetAppCategoriesViewModel()..loadFirstPage());

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
