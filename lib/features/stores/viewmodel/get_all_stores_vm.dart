import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

/// The query one [GetAllStoresViewModel] pages through the `/api/v1/stores`
/// endpoint: optionally narrowed to a [categoryId], a [rating] filter and a
/// [searchKey] text filter. Used as the [getAllStoresProvider] family key, so
/// each distinct query keeps its own independent pagination state (e.g. every
/// store tab on the home / All Stores screen, and the same tab with vs. without
/// a rating or search filter).
typedef AllStoresArgs = ({
  int? categoryId,
  String? rating,
  String? searchKey,
});

final getAllStoresProvider = StateNotifierProvider.autoDispose.family<
    GetAllStoresViewModel,
    AsyncValue<PaginationModel<StoreModel>>,
    AllStoresArgs>(
  (Ref ref, AllStoresArgs args) =>
      GetAllStoresViewModel(args: args)..loadFirstPage(),
);

class GetAllStoresViewModel extends PaginatedViewModel<StoreModel> {
  GetAllStoresViewModel({required this.args});

  final StoresRepo _repo = StoresRepo();

  final AllStoresArgs args;

  void updateStoreFavourite(int? storeId, bool isFavourite) {
    if (storeId == null) return;
    updateItemsWhere(
      (StoreModel store) => store.id == storeId,
      (StoreModel store) => store.copyWith(isFavorite: isFavourite),
    );
  }

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) {
    return _repo.getStores(
      page: page,
      search: args.searchKey,
      categoryId: args.categoryId,
      rating: args.rating,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
