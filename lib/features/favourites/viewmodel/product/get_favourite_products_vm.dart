import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';

/// Single task: page through the caller's favourited products for the
/// favourites Products tab.
///
/// The first page is kicked off on first watch; `loadNextPage()` and
/// `loadFirstPage()` (refresh / retry) are inherited from [PaginatedViewModel].
final getFavouriteProductsProvider = StateNotifierProvider.autoDispose<
    GetFavouriteProductsViewModel,
    AsyncValue<PaginationModel<ProductModel>>>(
  (Ref ref) => GetFavouriteProductsViewModel()..loadFirstPage(),
);

class GetFavouriteProductsViewModel extends PaginatedViewModel<ProductModel> {
  final FavouritesRepo _repo = FavouritesRepo();

  /// The active filters, replayed by every page load, refresh and retry.
  String? _search;
  List<int> _categoryIds = const <int>[];
  String? _sort;

  /// Swaps the filters and reloads from the first page. The pages already
  /// loaded are dropped — they belong to the previous query.
  Future<void> applyFilters({
    String? search,
    List<int>? categoryIds,
    String? sort,
  }) {
    _search = search;
    _categoryIds = categoryIds ?? const <int>[];
    _sort = sort;
    return loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) {
    return _repo.getFavouriteProducts(
      page: page,
      search: _search,
      categoryIds: _categoryIds,
      sort: _sort,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
