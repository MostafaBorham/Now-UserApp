import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';

/// The stores of the opened category as an infinite-scrolling list.
///
/// Only describes *what* the list shows — the paging behaviour (next page on
/// scroll, pull-to-refresh, loading, empty and error states) lives in
/// [PaginatedView] and [GetCategoryStoresViewModel].
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
  late final GetCategoryStoresViewModel _storesViewModel;

  @override
  void initState() {
    super.initState();
    _storesViewModel = ref.read(getCategoryStoresProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStores());
  }

  /// Loads the first page of the opened category. Also the pull-to-refresh and
  /// first-page retry action, so all three ask for the same query.
  Future<void> _fetchStores() {
    // TODO: forward widget.sortType to the API once the stores sort param is wired.
    return _storesViewModel.getCategoryStores(
      categorySlug: ref.read(categoryProvider).slug ?? '',
      categoryId: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedView<StoreModel>(
      provider: getCategoryStoresProvider,
      onRefresh: _fetchStores,
      onLoadNextPage: _storesViewModel.loadNextPage,
      layout: PaginatedListLayout(
        padding: EdgeInsets.zero,
        separatorBuilder: (BuildContext context, int index) => 20.hSpace,
      ),
      // Fills the list while the first page loads and trails it while the next
      // one does, so the skeleton always matches the real cards.
      placeholderBuilder: (BuildContext context) => const AspectRatio(
        aspectRatio: 2,
        child: AppShimmer(child: StoreItem()),
      ),
      itemBuilder: (BuildContext context, StoreModel store, int index) =>
          AspectRatio(
        aspectRatio: 2,
        child: StoreItem(storeModel: store),
      ),
    );
  }
}
