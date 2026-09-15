import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';






typedef CategoryStoresArgs = ({
  String categorySlug,
  int? categoryId,
  String? searchKey,
});








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



  final CategoryStoresArgs args;






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
