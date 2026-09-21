import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/all_stores/stores_search_filter_provider.dart';
import 'package:nowdelivery_user_app/features/stores/viewmodel/get_all_stores_vm.dart';

/// One store tab on [AllStoresScreen]. Every tab pages [getAllStoresProvider]
/// (`/api/v1/stores`) — the same provider the home screen uses. The "All" tab
/// passes no [category]; every other tab narrows the query by its [category]'s
/// id, and the rating/search filters are forwarded alongside.
///
/// It listens to [storesSearchFilterProvider] and only the tab whose [category]
/// matches the selection queries its stores (forwarding the rating and search
/// filters); unselected tabs stay skeleton placeholders.
class StoresListView extends ConsumerWidget {
  const StoresListView({super.key, this.category});

  final CategoryModel? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? categoryId = category?.id;
    final StoresSearchFilter filter = ref.watch(storesSearchFilterProvider);

    final bool isSelected = filter.categoryId == categoryId;
    if (!isSelected) {
      return ListView.separated(
        padding: const EdgeInsets.all(2),
        itemBuilder: (context, index) => const AspectRatio(
          aspectRatio: 1.5,
          child: AppShimmer(child: StoreCardView()),
        ),
        separatorBuilder: (context, index) => 15.hSpace,
        itemCount: 5,
      );
    }

    final String? searchKey = filter.search.isEmpty ? null : filter.search;
    final String? rating = filter.rating.isEmpty ? null : filter.rating;

    final AllStoresArgs args = (
      categoryId: categoryId,
      rating: rating,
      searchKey: searchKey,
    );
    final GetAllStoresViewModel viewModel = ref.read(
      getAllStoresProvider(args).notifier,
    );

    return PaginatedView<StoreModel>(
      provider: getAllStoresProvider(args),
      onRefresh: viewModel.loadFirstPage,
      onLoadNextPage: viewModel.loadNextPage,
      layout: PaginatedListLayout(
        padding: const EdgeInsets.all(2),
        separatorBuilder: (context, index) => 15.hSpace,
      ),
      placeholderBuilder: (context) => const AspectRatio(
        aspectRatio: 1.5,
        child: AppShimmer(child: StoreCardView()),
      ),
      itemBuilder: (context, store, index) => AspectRatio(
        aspectRatio: 1.5,
        child: StoreCardView(
          store: store,
          onFavouriteChanged: (bool isFavourite) =>
              viewModel.updateStoreFavourite(store.id, isFavourite),
        ),
      ),
    );
  }
}
