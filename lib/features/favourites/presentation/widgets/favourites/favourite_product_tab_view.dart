import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourites_tab_view.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/get_favourite_products_vm.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/cards/product_item_card2.dart';

/// The caller's favourited products: search + category chips + sort over an
/// infinite-scrolling grid. The filter chrome lives in [FavouritesTabView]; the
/// paging behaviour lives in [PaginatedView] and [GetFavouriteProductsViewModel].
///
/// Kept alive across tab switches so returning to it does not refetch (its
/// provider stays watched) and the search / chip / sort selection survives.
class FavouriteProductTabView extends ConsumerStatefulWidget {
  const FavouriteProductTabView({super.key});

  @override
  ConsumerState<FavouriteProductTabView> createState() =>
      _FavouriteProductTabViewState();
}

class _FavouriteProductTabViewState
    extends ConsumerState<FavouriteProductTabView>
    with AutomaticKeepAliveClientMixin {
  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final GetFavouriteProductsViewModel viewModel =
        ref.read(getFavouriteProductsProvider.notifier);

    return FavouritesTabView(
      type: 'product',
      searchHintKey: LangKeys.searchForAProductKey,
      onFiltersChanged: (String? search, List<int> categoryIds, String? sort) =>
          viewModel.applyFilters(
        search: search,
        categoryIds: categoryIds,
        sort: sort,
      ),
      child: PaginatedView<ProductModel>(
        provider: getFavouriteProductsProvider,
        onRefresh: viewModel.loadFirstPage,
        onLoadNextPage: viewModel.loadNextPage,
        layout: const PaginatedGridLayout(
          gridDelegate: _gridDelegate,
          padding: EdgeInsets.all(4),
        ),
        placeholderBuilder: (BuildContext context) =>
            AppShimmer(child: ProductItemCard2(onTap: () {})),
        itemBuilder: (BuildContext context, ProductModel product, int index) =>
            ProductItemCard2(
          productModel: product,
          // Unfavouriting from the list removes the card right away instead of
          // waiting for a refresh.
          onFavouriteChanged: (bool isFavourite) {
            if (!isFavourite && product.id != null) {
              viewModel.removeItemsWhere(
                (ProductModel p) => p.id == product.id,
              );
            }
          },
        ),
      ),
    );
  }
}
