import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';






typedef FavouriteStoresArgs = ({int? categoryId, String? searchKey});








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



  final FavouriteStoresArgs args;



  void updateStoreFavourite(int? storeId, bool isFavourite) {
    if (storeId == null) return;
    updateItemsWhere(
      (StoreModel store) => store.id == storeId,
      (StoreModel store) => store.copyWith(isFavorite: isFavourite),
    );
  }

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
