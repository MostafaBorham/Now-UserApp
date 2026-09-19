import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// The query one [GetFavouriteStoresViewModel] pages through: the caller's
/// favourited stores, optionally narrowed to a single app [categoryId]
/// (`null` = the "All" tab) and a [searchKey] text filter. Used as the
/// [getFavouriteStoresProvider] family key, so each category tab — and the same
/// tab with vs. without a search term — keeps its own pagination state.
typedef FavouriteStoresArgs = ({int? categoryId, String? searchKey});

/// Single task: page through the caller's favourited stores for one category
/// tab of the favourites Stores tab.
///
/// A `family` keyed by [FavouriteStoresArgs]: each query gets its own view
/// model and state, so switching category tabs never clobbers another tab's
/// stores. The first page is kicked off on first watch; `loadNextPage()` and
/// `loadFirstPage()` (refresh / retry) are inherited from [PaginatedViewModel].
final getFavouriteStoresProvider = StateNotifierProvider.autoDispose.family<
    GetFavouriteStoresViewModel,
    AsyncValue<PaginationModel<StoreModel>>,
    FavouriteStoresArgs>(
  (Ref ref, FavouriteStoresArgs args) =>
      GetFavouriteStoresViewModel(args: args)..loadFirstPage(),
);

class GetFavouriteStoresViewModel extends PaginatedViewModel<StoreModel> {
  GetFavouriteStoresViewModel({required this.args});

  final FavouritesRepo _repo = FavouritesRepo();

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same stores.
  final FavouriteStoresArgs args;

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) {
    return _repo.getFavouriteStores(
      page: page,
      search: args.searchKey,
      categoryIds:
          args.categoryId == null ? null : <int>[args.categoryId!],
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
