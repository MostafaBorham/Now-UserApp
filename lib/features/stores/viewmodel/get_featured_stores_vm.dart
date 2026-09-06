import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

/// Single task: page through the platform's featured stores.
///
/// The home "Best brands" carousel (which takes the first few off page one) and
/// the "view all" top-brands screen (which infinite-scrolls the full list) share
/// this one state. Kept alive (not `autoDispose`), like `getAppCategoriesProvider`:
/// the home screen loads the first page once and the top-brands screen reuses it
/// instead of refetching. `loadNextPage()` / `loadFirstPage()` (scroll / refresh
/// / retry) come from [PaginatedViewModel].
final getFeaturedStoresProvider = StateNotifierProvider<
    GetFeaturedStoresViewModel, AsyncValue<PaginationModel<StoreModel>>>(
  (Ref ref) => GetFeaturedStoresViewModel()..loadFirstPage(),
);

class GetFeaturedStoresViewModel extends PaginatedViewModel<StoreModel> {
  final StoresRepo _repo = StoresRepo();

  @override
  Future<Either<Failure, PaginationModel<StoreModel>>> fetchPage(int page) {
    return _repo.getFeaturedStores(page: page);
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
