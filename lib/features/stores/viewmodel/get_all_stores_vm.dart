import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

final getAllStoresProvider = StateNotifierProvider.autoDispose<
    GetAllStoresViewModel, AsyncValue<PaginationModel<StoreModel>>>(
  (Ref ref) => GetAllStoresViewModel()..loadFirstPage(),
);

class GetAllStoresViewModel extends PaginatedViewModel<StoreModel> {
  final StoresRepo _repo = StoresRepo();

  void updateStoreFavourite(int? storeId, bool isFavourite) {
    if (storeId == null) return;
    updateItemsWhere(
      (StoreModel store) => store.id == storeId,
      (StoreModel store) => store.copyWith(isFavorite: isFavourite),
    );
  }

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) {
    return _repo.getStores(page: page);
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
