import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/products/product_details_list_scope.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/providers/favourites_filter_provider.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/favourite_categories_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/product/get_favourite_products_vm.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

/// One category tab of the favourites Products tab. The "All" tab passes no
/// [categoryId] and lists every favourited product; every other tab is bound to
/// its own [categoryId].
///
/// It listens to [favouritesFilterProvider] for `product` and, whenever it
/// changes, checks whether the selected category is this view's [categoryId].
/// Only then does it query [getFavouriteProductsProvider] — forwarding the
/// search key and its own category id — and render the products. Otherwise it
/// stays a shimmer placeholder, so only the visible tab paginates.
class FavouriteProductsListView extends ConsumerWidget {
  const FavouriteProductsListView({super.key, this.categoryId});

  final int? categoryId;

  static const SliverGridDelegate _gridDelegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.7,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FavouritesFilter filter = ref.watch(
      favouritesFilterProvider('product'),
    );

    final bool isSelected = filter.categoryId == categoryId;
    if (!isSelected) {
      return GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: _gridDelegate,
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) =>
            const AppShimmer(child: ProductItem3View()),
      );
    }

    final FavouriteProductsArgs args = (
      categoryId: categoryId,
      searchKey: filter.search.isEmpty ? null : filter.search,
    );
    final GetFavouriteProductsViewModel viewModel = ref.read(
      getFavouriteProductsProvider(args).notifier,
    );

    return ProductDetailsListScope(
      productSlugs: () =>
          ref
              .read(getFavouriteProductsProvider(args))
              .valueOrNull
              ?.data
              .map((product) => product.slug) ??
          const <String>[],
      child: PaginatedView<ProductModel>(
        provider: getFavouriteProductsProvider(args),
        onRefresh: viewModel.loadFirstPage,
        onLoadNextPage: viewModel.loadNextPage,
        layout: PaginatedGridLayout(
          gridDelegate: _gridDelegate,
          padding: const EdgeInsets.all(
            4,
          ).copyWith(bottom: 4 + MediaQuery.paddingOf(context).bottom),
        ),
        placeholderBuilder: (BuildContext context) =>
            const AppShimmer(child: ProductItem3View()),
        // Near the top: centred, it sat low, under the header, tabs and search,
        // and behind the floating nav bar.
        emptyBuilder: (BuildContext context) => NoResultsWidget(
          isScrollable: true,
          alignTop: true,
          image: Assets.media.images.svg.emptyFavourite.svg(),
          emptyMessage:
              (args.searchKey == null
                      ? LangKeys.noFavouriteProductsKey
                      : LangKeys.noSearchMatchesKey)
                  .tr(),
        ),
        itemBuilder: (BuildContext context, ProductModel product, int index) => ProductItem3View(
          product: product,
          // Unfavouriting drops just this card in place — scroll position and the
          // already-loaded pages are kept. removeItemsWhere reloads the first page
          // itself only if the visible page empties out with more still on the
          // server.
          onFavouriteChanged: (bool isFavourite) {
            if (!isFavourite) {
              viewModel.removeItemsWhere(
                (ProductModel item) => item.id == product.id,
              );
              // Refresh the category chips so one with no remaining favourites
              // drops out (BUG-038). FavouritesTabView then falls the tab back to
              // "All" when the selected category disappears.
              ref
                  .read(favouriteCategoriesProvider('product').notifier)
                  .refresh();
            }
          },
        ),
      ),
    );
  }
}
