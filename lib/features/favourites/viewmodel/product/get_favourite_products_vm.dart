import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/favourites/data/repo/favourites_repo.dart';






typedef FavouriteProductsArgs = ({int? categoryId, String? searchKey});








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



  final FavouriteProductsArgs args;




  void updateProductFavourite(int? productId, bool isFavourite) {
    if (productId == null) return;
    updateItemsWhere(
      (ProductModel product) => product.id == productId,
      (ProductModel product) => product.copyWith(isFavorite: isFavourite),
    );
  }

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
