import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

/// The search screen's own categories list, narrowed by the search term.
///
/// Tied to the search screen only: `autoDispose`, so it is created when the
/// screen opens and torn down when it closes — a searched term's pages never
/// linger and never mutate the shared, app-wide [getAppCategoriesProvider].
///
/// Its initial (unfiltered) data is seeded straight from that shared provider —
/// the full list the splash preloads — so opening search shows the categories
/// with no request. Only when that shared list has nothing yet (never loaded,
/// or errored) does this VM fetch the unfiltered first page itself. Applying a
/// term ([SearchCategoriesViewModel.search]) then fetches the filtered list;
/// clearing it back to empty returns to the seeded unfiltered list.
///
/// This is the split the app relies on: the unfiltered [getAppCategoriesProvider]
/// stays the single app-wide source, while the filtered search list lives and
/// dies with the search screen here.
final searchCategoriesProvider = StateNotifierProvider.autoDispose<
    SearchCategoriesViewModel, AsyncValue<PaginationModel<CategoryModel>>>(
  (Ref ref) => SearchCategoriesViewModel(ref),
);

class SearchCategoriesViewModel extends PaginatedViewModel<CategoryModel> {
  SearchCategoriesViewModel(this._ref) {
    _showUnfiltered();
  }

  final Ref _ref;
  final CategoriesRepo _repo = CategoriesRepo();

  /// The term the list is currently narrowed by; empty means the full list.
  /// Stored so [loadFirstPage] (initial fetch, refresh, retry) replays it.
  String _searchKey = '';

  String get searchKey => _searchKey;

  /// Applies (or clears) the search term. An empty term returns to the shared
  /// unfiltered list without a request; a real term fetches the filtered list.
  /// A no-op when the term is unchanged, so repeated debounce ticks don't
  /// refetch the same query.
  void search(String term) {
    final String trimmed = term.trim();
    if (trimmed == _searchKey) return;
    if (trimmed.isEmpty) {
      _showUnfiltered();
    } else {
      _searchKey = trimmed;
      loadFirstPage();
    }
  }

  /// Seeds the unfiltered list from the shared [getAppCategoriesProvider]
  /// without a request; only if that provider has no data yet does it fetch the
  /// first page here (via [fetchPage] with no term).
  void _showUnfiltered() {
    _searchKey = '';
    final PaginationModel<CategoryModel>? preloaded =
        _ref.read(getAppCategoriesProvider).valueOrNull;
    if (preloaded != null) {
      state = AsyncValue<PaginationModel<CategoryModel>>.data(preloaded);
    } else {
      loadFirstPage();
    }
  }

  @override
  Future<Either<Failure, PaginationModel<CategoryModel>>> fetchPage(int page) {
    return _repo.getAppCategories(
      page: page,
      search: _searchKey.isEmpty ? null : _searchKey,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
