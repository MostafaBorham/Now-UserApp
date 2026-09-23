import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/features/categories/data/repo/categories_repo.dart';

/// The query one [GetCategoryProductsViewModel] pages through: a category's
/// [categorySlug], optionally narrowed to the sub-category [categoryId] and to a
/// [searchKey] text filter. Used as the [getCategoryProductsProvider] family key,
/// so each distinct query keeps its own independent pagination state (e.g. every
/// product tab on the category details screen, or the same tab with vs. without a
/// search term).
typedef CategoryProductsArgs = ({
  String categorySlug,
  int? categoryId,
  String? searchKey,
});

/// Single task: page through the products of a category for the category
/// details screen.
///
/// A `family` keyed by [CategoryProductsArgs]: each query gets its own view model
/// and state, so several tabs paging different queries at once never share (or
/// clobber) each other's products. The first page starts as soon as an arg is
/// first watched; `loadNextPage()` and `loadFirstPage()` (refresh / retry) then
/// replay the same query from [PaginatedViewModel].
final getCategoryProductsProvider = StateNotifierProvider.autoDispose.family<
    GetCategoryProductsViewModel,
    AsyncValue<PaginationModel<ProductModel>>,
    CategoryProductsArgs>(
  (Ref ref, CategoryProductsArgs args) =>
      GetCategoryProductsViewModel(args: args)..loadFirstPage(),
);

class GetCategoryProductsViewModel extends PaginatedViewModel<ProductModel> {
  GetCategoryProductsViewModel({required this.args});

  final CategoriesRepo _repo = CategoriesRepo();

  /// The query the loaded pages belong to, kept so that loading another page,
  /// refreshing or retrying asks for the same products.
  final CategoryProductsArgs args;

  /// Flips [ProductModel.isFavorite] on the single loaded product with
  /// [productId] in place, leaving the rest of the list (and its scroll
  /// position) untouched. Called when the favourite icon on a card reports a
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
    return _repo.getCategoryProducts(
      categorySlug: args.categorySlug,
      categoryId: args.categoryId,
      page: page,
      search: args.searchKey,
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
