import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

typedef StoreCategoryProductsArgs = ({
  int storeId,
  int? categoryId,
  ProductFilters filter,
});

final getStoreCategoryProductsProvider = StateNotifierProvider.autoDispose
    .family<
      GetStoreCategoryProductsViewModel,
      AsyncValue<PaginationModel<ProductModel>>,
      StoreCategoryProductsArgs
    >(
      (Ref ref, StoreCategoryProductsArgs args) =>
          GetStoreCategoryProductsViewModel(args: args)..loadFirstPage(),
    );

class GetStoreCategoryProductsViewModel
    extends PaginatedViewModel<ProductModel> {
  GetStoreCategoryProductsViewModel({required this.args});

  final StoresRepo _repo = StoresRepo();

  final StoreCategoryProductsArgs args;

  void updateProductFavourite(int? productId, bool isFavourite) {
    if (productId == null) return;
    updateItemsWhere(
      (ProductModel product) => product.id == productId,
      (ProductModel product) => product.copyWith(isFavorite: isFavourite),
    );
  }

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) {
    return _repo.getStoreCategoryProducts(
      storeId: args.storeId,
      categoryId: args.categoryId,
      filter: args.filter.queryValue,
      page: page,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
