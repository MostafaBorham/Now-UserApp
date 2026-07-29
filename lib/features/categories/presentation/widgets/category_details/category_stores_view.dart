import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/store_item.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/providers/category_details/category_model_provider.dart';
import 'package:nowdelivery_user_app/features/categories/presentation/widgets/category_details/category_stores_view_shimmer.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_category_stores_vm.dart';

class CategoryStoresView extends ConsumerStatefulWidget {
  const CategoryStoresView({
    super.key, required this.sortType,
  });
  final StoresSortType sortType;

  @override
  ConsumerState<CategoryStoresView> createState() => _CategoryStoresViewState();
}

class _CategoryStoresViewState extends ConsumerState<CategoryStoresView> {
  late final GetCategoryStoresViewModel storesViewModel ;
  @override
  void initState() {
    super.initState();

    storesViewModel = ref.read(getCategoryStoresProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStores();
    },);

  }

  void _fetchStores(){
    // TODO: forward widget.sortType to the API once the stores sort param is wired.
    storesViewModel.getCategoryStores(categorySlug: ref.read(categoryProvider).slug??'',categoryId: null);
  }
  @override
  Widget build(BuildContext context) {
    final storesState = ref.watch(getCategoryStoresProvider);
    return storesState.when(
      loading: () => CategoryStoresViewShimmer(),
      error: (Object error, StackTrace stackTrace) =>
          ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: () => _fetchStores(),
          ),
      data: (pagination) {
        final stores = pagination.data;
        return AppRefreshIndicator(
          onRefresh: ()async => _fetchStores(),
          child: stores.isEmpty? NoItemsWidget() : ListView.separated(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => AspectRatio(
                aspectRatio: 2,
                child: StoreItem(
                  storeModel: stores.elementAtOrNull(index),
                )),
            separatorBuilder: (context, index) => 20.hSpace,
            itemCount: stores.length,
          ),
        );
      },
    );
  }
}