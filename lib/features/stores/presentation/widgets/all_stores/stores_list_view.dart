import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/providers/all_stores/stores_search_filter_provider.dart';

/// One store tab on [AllStoresScreen]. The "All" tab passes no [category] and
/// shows demo placeholder cards; every other tab is bound to its own [category].
///
/// It listens to [storesSearchFilterProvider] and, whenever it changes, checks
/// whether the currently selected category is this view's [category]. Only then
/// does it query [getCategoryStoresProvider] — forwarding the search key and its
/// own category slug — and render the stores. Otherwise it stays a placeholder.
class StoresListView extends ConsumerWidget {
  const StoresListView({super.key, this.category});

  final CategoryModel? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CategoryModel? category = this.category;

    // "All" tab: no category wired to a data source yet — demo placeholder cards.
    if (category == null) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemBuilder: (context, index) => const AspectRatio(
          aspectRatio: 1.5,
          child: StoreCardView(),
        ),
        separatorBuilder: (context, index) => 15.hSpace,
        itemCount: 5,
      );
    }

    final StoresSearchFilter filter = ref.watch(storesSearchFilterProvider);

    final bool isSelected = filter.category == category;
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

    final CategoryStoresArgs args = (
      categorySlug: category.slug ?? '',
      categoryId: null,
      searchKey: filter.search.isEmpty ? null : filter.search,
    );
    final GetCategoryStoresViewModel viewModel =
        ref.read(getCategoryStoresProvider(args).notifier);

    return PaginatedView<StoreModel>(
      provider: getCategoryStoresProvider(args),
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
