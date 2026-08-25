import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// The query one [GetCategoryStoresViewModel] pages through: a category's
/// [categorySlug], optionally narrowed to the sub-category [categoryId] and to a
/// [searchKey] text filter. Used as the [getCategoryStoresProvider] family key,
/// so each distinct query keeps its own independent pagination state (e.g. every
/// store tab on the home screen, or the same tab with vs. without a search term).
typedef CategoryStoresArgs = ({
  String categorySlug,
  int? categoryId,
  String? searchKey,
});

/// Single task: page through the stores of a category.
///
/// A `family` keyed by [CategoryStoresArgs]: each query gets its own view model
/// and state, so several tabs paging different categories at once never share
/// (or clobber) each other's stores. The first page starts as soon as an arg is
/// first watched; `loadNextPage()` and `loadFirstPage()` (refresh / retry) then
/// replay the same query from [PaginatedViewModel].
final getCategoryStoresProvider = StateNotifierProvider.autoDispose.family<
    GetCategoryStoresViewModel,
    AsyncValue<PaginationModel<StoreModel>>,
    CategoryStoresArgs>(
  (Ref ref, CategoryStoresArgs args) =>
      GetCategoryStoresViewModel(args: args)..loadFirstPage(),
);

class GetCategoryStoresViewModel extends PaginatedViewModel<StoreModel> {
  GetCategoryStoresViewModel({required this.args});

  final CategoriesRepo _repo = CategoriesRepo();

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same stores.
  final CategoryStoresArgs args;

  /// Flips [StoreModel.isFavorite] on the single loaded store with [storeId] in
  /// place, leaving the rest of the list (and its scroll position) untouched.
  /// Called when a store card's favourite icon reports a settled change, so a
  /// card scrolled off and back keeps the new status instead of reverting to
  /// the server-loaded one.
  void updateStoreFavourite(int? storeId, bool isFavourite) {
    if (storeId == null) return;
    updateItemsWhere(
      (StoreModel store) => store.id == storeId,
      (StoreModel store) => store.copyWith(isFavorite: isFavourite),
    );
  }

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) {
    return _repo.getCategoryStores(
      categorySlug: args.categorySlug,
      categoryId: args.categoryId,
      search: args.searchKey,
      page: page,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
