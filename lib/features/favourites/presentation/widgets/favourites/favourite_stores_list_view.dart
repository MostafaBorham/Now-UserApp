import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/empty_favourites_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/providers/favourites_filter_provider.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/favourite_categories_vm.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/get_favourite_stores_vm.dart';

/// One category tab of the favourites Stores tab. The "All" tab passes no
/// [categoryId] and lists every favourited store; every other tab is bound to
/// its own [categoryId].
///
/// It listens to [favouritesFilterProvider] for `vendor` and, whenever it
/// changes, checks whether the selected category is this view's [categoryId].
/// Only then does it query [getFavouriteStoresProvider] — forwarding the search
/// key and its own category id — and render the stores. Otherwise it stays a
/// shimmer placeholder, so only the visible tab paginates.
class FavouriteStoresListView extends ConsumerWidget {
  const FavouriteStoresListView({super.key, this.categoryId});

  final int? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FavouritesFilter filter =
        ref.watch(favouritesFilterProvider('vendor'));

    final bool isSelected = filter.categoryId == categoryId;
    if (!isSelected) {
      return ListView.separated(
        padding: const EdgeInsets.all(4),
        itemCount: 3,
        separatorBuilder: (BuildContext context, int index) => 20.hSpace,
        itemBuilder: (BuildContext context, int index) => const AspectRatio(
          aspectRatio: 1.75,
          child: AppShimmer(child: StoreCardView()),
        ),
      );
    }

    final FavouriteStoresArgs args = (
      categoryId: categoryId,
      searchKey: filter.search.isEmpty ? null : filter.search,
    );
    final GetFavouriteStoresViewModel viewModel =
        ref.read(getFavouriteStoresProvider(args).notifier);

    return PaginatedView<StoreModel>(
      provider: getFavouriteStoresProvider(args),
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
      layout: PaginatedListLayout(
        padding: const EdgeInsets.all(4).copyWith(
          bottom: 4 + MediaQuery.paddingOf(context).bottom,
        ),
        separatorBuilder: (BuildContext context, int index) => 20.hSpace,
      ),
      placeholderBuilder: (BuildContext context) => const AspectRatio(
        aspectRatio: 1.75,
        child: AppShimmer(child: StoreCardView()),
      ),
      emptyBuilder: (BuildContext context) =>
          const EmptyFavouritesWidget(isScrollable: true),
      itemBuilder: (BuildContext context, StoreModel store, int index) =>
          AspectRatio(
        aspectRatio: 1.75,
        child: StoreCardView(
          store: store,
          // Unfavouriting drops just this card in place — scroll position and
          // the already-loaded pages are kept. removeItemsWhere reloads the
          // first page itself only if the visible page empties out with more
          // still on the server.
          onFavouriteChanged: (bool isFavourite) {
            if (!isFavourite) {
              viewModel.removeItemsWhere(
                (StoreModel item) => item.id == store.id,
              );
              // Refresh the category chips so one with no remaining favourites
              // drops out (BUG-038). FavouritesTabView then falls the tab back
              // to "All" when the selected category disappears.
              ref
                  .read(favouriteCategoriesProvider('vendor').notifier)
                  .refresh();
            }
          },
        ),
      ),
    );
  }
}
