import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/products/data/repo/products_repo.dart';

/// The product search results for one term, paged. A `family` keyed by the
/// search term, so every term keeps its own pagination state.
final getProductsProvider = StateNotifierProvider.autoDispose.family<
    GetProductsViewModel, AsyncValue<PaginationModel<ProductModel>>, String>(
  (Ref ref, String search) =>
      GetProductsViewModel(search: search)..loadFirstPage(),
);

class GetProductsViewModel extends PaginatedViewModel<ProductModel> {
  GetProductsViewModel({required this.search});

  final ProductsRepo _repo = ProductsRepo();

  final String search;

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  void updateProductFavourite(int? productId, bool isFavourite) {
    if (productId == null) return;
    updateItemsWhere(
      (ProductModel product) => product.id == productId,
      (ProductModel product) => product.copyWith(isFavorite: isFavourite),
    );
  }

  @override
  Future<Either<Failure, PaginationModel<ProductModel>>> fetchPage(int page) {
    return _repo.getProducts(page: page, search: search);
  }
}
