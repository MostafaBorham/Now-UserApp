import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// The query one [GetFavouriteProductsViewModel] pages through: the caller's
/// favourited products, optionally narrowed to a single app [categoryId]
/// (`null` = the "All" tab) and a [searchKey] text filter. Used as the
/// [getFavouriteProductsProvider] family key, so each category tab — and the
/// same tab with vs. without a search term — keeps its own pagination state.
typedef FavouriteProductsArgs = ({int? categoryId, String? searchKey});

/// Single task: page through the caller's favourited products for one category
/// tab of the favourites Products tab.
///
/// A `family` keyed by [FavouriteProductsArgs]: each query gets its own view
/// model and state, so switching category tabs never clobbers another tab's
/// products. The first page is kicked off on first watch; `loadNextPage()` and
/// `loadFirstPage()` (refresh / retry) are inherited from [PaginatedViewModel].
final getFavouriteProductsProvider = StateNotifierProvider.autoDispose.family<
    GetFavouriteProductsViewModel,
    AsyncValue<PaginationModel<ProductModel>>,
    FavouriteProductsArgs>(
  (Ref ref, FavouriteProductsArgs args) =>
      GetFavouriteProductsViewModel(args: args)..loadFirstPage(),
);

class GetFavouriteProductsViewModel extends PaginatedViewModel<ProductModel> {
  GetFavouriteProductsViewModel({required this.args});

  final FavouritesRepo _repo = FavouritesRepo();

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same products.
  final FavouriteProductsArgs args;

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) {
    return _repo.getFavouriteProducts(
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
