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
final getAppCategoriesProvider =
    StateNotifierProvider<GetAppCategoriesViewModel,
        AsyncValue<PaginationModel<CategoryModel>>>(
  (Ref ref) => GetAppCategoriesViewModel()..loadFirstPage(),
);

/// The app categories narrowed by a search term, one paginated instance per
/// term (like `getCategoryStoresProvider`).
///
/// Kept separate from the shared, kept-alive [getAppCategoriesProvider] on
/// purpose: this one `autoDispose`s so a searched term's pages don't linger,
/// and searching never mutates the full list the splash preloads and the home
/// carousel reuses. Feed it the debounced term — every distinct term is a new
/// family member with its own pagination state — and it fetches on first watch.
final searchAppCategoriesProvider =
    StateNotifierProvider.autoDispose.family<GetAppCategoriesViewModel,
        AsyncValue<PaginationModel<CategoryModel>>, String>(
  (Ref ref, String search) =>
      GetAppCategoriesViewModel(searchKey: search)..loadFirstPage(),
);

class GetAppCategoriesViewModel extends PaginatedViewModel<CategoryModel> {
  GetAppCategoriesViewModel({this.searchKey});

  /// The term to narrow the list by; `null`/empty means the full list.
  final String? searchKey;

  final CategoriesRepo _repo = CategoriesRepo();

  @override
  Future<Either<Failure, PaginationModel<CategoryModel>>> fetchPage(int page) {
    return _repo.getAppCategories(page: page, search: searchKey);
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
