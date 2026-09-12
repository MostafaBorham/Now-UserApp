import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/stores/store_card_view.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_stores_search_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_stores_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';

/// The stores of the opened category as an infinite-scrolling list.
///
/// Mirrors [CategoryProductsView]: a manual [ScrollController] drives next-page
/// loading, and the coarse view shape (first-load shimmer, empty, error,
/// trailing next-page shimmer) is read off the view model's paginated state via
/// [PaginationStatus] instead of the generic `PaginatedView`.
class CategoryStoresView extends ConsumerStatefulWidget {
  const CategoryStoresView({
    super.key,
    required this.sortType,
  });
  final StoresSortType sortType;

  @override
  ConsumerState<CategoryStoresView> createState() => _CategoryStoresViewState();
}

class _CategoryStoresViewState extends ConsumerState<CategoryStoresView> {
  final ScrollController _scrollController = ScrollController();

  /// The query currently on screen. Recomputed in [build] from the debounced
  /// search term, so [_onScroll] always pages the family member being shown.
  // TODO: forward widget.sortType to the API once the stores sort param is wired.
  late CategoryStoresArgs _args;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // Only load more once the very end of the list is fully visible on screen.
    // `extentAfter` is the amount of scrollable content still hidden below the
    // viewport, so it reaches 0 exactly when no part of the list tail is
    // clipped off-screen. `loadNextPage` is itself a no-op unless another page
    // may be requested, so calling it on every such frame is safe.
    if (_scrollController.position.extentAfter <= 0) {
      ref.read(getCategoryStoresProvider(_args).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // React to the debounced search term: each distinct query is its own family
    // member with independent pagination state.
    final String search = ref.watch(categoryStoresSearchProvider);
    _args = (
      categorySlug: ref.read(categoryProvider).slug ?? '',
      categoryId: null,
      searchKey: search.isEmpty ? null : search,
    );

    final GetCategoryStoresViewModel viewModel =
        ref.read(getCategoryStoresProvider(_args).notifier);

    // Surface a failed next-page load without disturbing the list. The message
    // stays in state until the next load settles, so this only fires when it
    // actually changes.
    ref.listen<String?>(
      getCategoryStoresProvider(_args).select(
        (AsyncValue<PaginationModel<StoreModel>> state) =>
            PaginationStatus<StoreModel>.from(state).nextPageError,
      ),
      (String? previous, String? next) {
        if (next != null && mounted) AppToast.showError(context, next);
      },
    );

    // Watch only the coarse view shape — first-load / error / item count /
    // whether a next page is in flight — not the stores themselves. Appending a
    // page keeps every existing store's identity, so those items never rebuild;
    // only the trailing shimmer count and length change here.
    final ({
      bool isFirstPageLoading,
      String? firstPageError,
      bool isNextPageLoading,
      int length,
    }) view = ref.watch(
      getCategoryStoresProvider(_args).select(
        (AsyncValue<PaginationModel<StoreModel>> state) {
          final PaginationStatus<StoreModel> status =
              PaginationStatus<StoreModel>.from(state);
          return (
            isFirstPageLoading: status.isFirstPageLoading,
            firstPageError: status.firstPageError,
            isNextPageLoading: status.isNextPageLoading,
            length: status.items.length,
          );
        },
      ),
    );

    if (view.isFirstPageLoading) return const CategoryStoresViewShimmer();
    if (view.firstPageError != null) {
      return ServerConnectionErrorWidget(
        message: view.firstPageError!,
        onRetry: viewModel.loadFirstPage,
      );
    }

    final int loadingItemsCount = view.isNextPageLoading ? 4 : 0;

    return AppRefreshIndicator(
      onRefresh: viewModel.loadFirstPage,
      child: view.length == 0
          ? const NoResultsWidget(isScrollable: true)
          : ListView.separated(
              controller: _scrollController,
              addRepaintBoundaries: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(4),
              itemCount: view.length + loadingItemsCount,
              separatorBuilder: (BuildContext context, int index) => 20.hSpace,
              itemBuilder: (BuildContext context, int index) {
                if (index >= view.length) {
                  return const AspectRatio(
                    aspectRatio: 1.75,
                    child: AppShimmer(child: StoreCardView()),
                  );
                }
                return _CategoryStoreItem(args: _args, index: index);
              },
            ),
    );
  }
}

/// A single store cell that watches **only its own store** in the paginated
/// state. Because appending a page keeps every already-loaded store's identity,
/// `select`'s `==` check leaves this cell untouched when the next page arrives —
/// only genuinely new cells build.
class _CategoryStoreItem extends ConsumerWidget {
  const _CategoryStoreItem({required this.args, required this.index});

  final CategoryStoresArgs args;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StoreModel? store = ref.watch(
      getCategoryStoresProvider(args).select(
        (AsyncValue<PaginationModel<StoreModel>> state) =>
            state.valueOrNull?.data.elementAtOrNull(index),
      ),
    );

    if (store == null) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1.75,
      child: StoreCardView(
        store: store,
        onFavouriteChanged: (bool isFavourite) => ref
            .read(getCategoryStoresProvider(args).notifier)
            .updateStoreFavourite(store.id, isFavourite),
      ),
    );
  }
}
