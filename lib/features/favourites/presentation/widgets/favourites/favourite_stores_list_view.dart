import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/empty_favourites_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/providers/favourites_filter_provider.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/get_favourite_stores_vm.dart';

/// One category tab of the favourites Stores tab. The "All" tab passes no
/// [category] and lists every favourited store; every other tab is bound to its
/// own [category].
///
/// It listens to [favouritesFilterProvider] for `vendor` and, whenever it
/// changes, checks whether the selected category is this view's [category].
/// Only then does it query [getFavouriteStoresProvider] — forwarding the search
/// key and its own category id — and render the stores. Otherwise it stays a
/// shimmer placeholder, so only the visible tab paginates.
class FavouriteStoresListView extends ConsumerWidget {
  const FavouriteStoresListView({super.key, this.category});

  final CategoryModel? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FavouritesFilter filter =
        ref.watch(favouritesFilterProvider('vendor'));

    final bool isSelected = filter.category == category;
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
      categoryId: category?.id,
      searchKey: filter.search.isEmpty ? null : filter.search,
    );
    final GetFavouriteStoresViewModel viewModel =
        ref.read(getFavouriteStoresProvider(args).notifier);

    return PaginatedView<StoreModel>(
      provider: getFavouriteStoresProvider(args),
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
      layout: PaginatedListLayout(
        padding: const EdgeInsets.all(4),
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
          // Unfavouriting from the list removes the card right away instead of
          // waiting for a refresh.
          onFavouriteChanged: (bool isFavourite) {
            if (!isFavourite && store.id != null) {
              viewModel.removeItemsWhere((StoreModel s) => s.id == store.id);
            }
          },
        ),
      ),
    );
  }
}
