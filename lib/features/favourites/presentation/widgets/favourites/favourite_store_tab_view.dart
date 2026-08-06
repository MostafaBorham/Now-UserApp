import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourites_tab_view.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/store/get_favourite_stores_vm.dart';

/// The caller's favourited stores: search + category chips + sort over an
/// infinite-scrolling list. The filter chrome lives in [FavouritesTabView]; the
/// paging behaviour lives in [PaginatedView] and [GetFavouriteStoresViewModel].
///
/// Kept alive across tab switches so returning to it does not refetch (its
/// provider stays watched) and the search / chip / sort selection survives.
class FavouriteStoreTabView extends ConsumerStatefulWidget {
  const FavouriteStoreTabView({super.key});

  @override
  ConsumerState<FavouriteStoreTabView> createState() =>
      _FavouriteStoreTabViewState();
}

class _FavouriteStoreTabViewState extends ConsumerState<FavouriteStoreTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final GetFavouriteStoresViewModel viewModel =
        ref.read(getFavouriteStoresProvider.notifier);

    return FavouritesTabView(
      type: 'vendor',
      searchHintKey: LangKeys.searchForAStoreKey,
      onFiltersChanged: (String? search, List<int> categoryIds, String? sort) =>
          viewModel.applyFilters(
        search: search,
        categoryIds: categoryIds,
        sort: sort,
      ),
      child: PaginatedView<StoreModel>(
        provider: getFavouriteStoresProvider,
        onRefresh: viewModel.loadFirstPage,
        onLoadNextPage: viewModel.loadNextPage,
        layout: PaginatedListLayout(
          padding: EdgeInsets.zero,
          separatorBuilder: (BuildContext context, int index) => 20.hSpace,
        ),
        placeholderBuilder: (BuildContext context) => const AspectRatio(
          aspectRatio: 2,
          child: AppShimmer(child: StoreItem()),
        ),
        itemBuilder: (BuildContext context, StoreModel store, int index) =>
            AspectRatio(
          aspectRatio: 2,
          child: StoreItem(
            storeModel: store,
            // Unfavouriting from the list removes the card right away instead
            // of waiting for a refresh.
            onFavouriteChanged: (bool isFavourite) {
              if (!isFavourite && store.id != null) {
                viewModel.removeItemsWhere((StoreModel s) => s.id == store.id);
              }
            },
          ),
        ),
      ),
    );
  }
}
