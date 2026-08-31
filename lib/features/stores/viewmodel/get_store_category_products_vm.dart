import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/enums/product_filters.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/stores/data/repo/stores_repo.dart';

/// The query one [GetStoreCategoryProductsViewModel] pages through: a store's
/// products, optionally narrowed to a single [categoryId] and always to a
/// [ProductFilters] filter (`all`, `top_rated`, …). Used as the
/// [getStoreCategoryProductsProvider] family key, so each distinct query keeps
/// its own independent pagination state — every filter tab on the store details
/// screen pages its own products without sharing (or clobbering) another tab's.
typedef StoreCategoryProductsArgs = ({
  int storeId,
  int? categoryId,
  ProductFilters filter,
});

/// Single task: page through the products of one store for the store details
/// screen (one family member per filter tab) and the view-store-category
/// products screen (one member per opened category).
///
/// A `family` keyed by [StoreCategoryProductsArgs]: the first page starts as
/// soon as an arg is first watched, then `loadNextPage()` and `loadFirstPage()`
/// (refresh / retry) replay the same query from [PaginatedViewModel].
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

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same products.
  final StoreCategoryProductsArgs args;

  /// Flips [ProductModel.isFavorite] on the single loaded product with
  /// [productId] in place, leaving the rest of the grid (and its scroll
  /// position) untouched. Called when a product card's favourite icon reports a
  /// settled change, so a card scrolled off and back keeps the new status
  /// instead of reverting to the server-loaded one.
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
