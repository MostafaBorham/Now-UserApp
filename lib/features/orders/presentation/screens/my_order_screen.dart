import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item_shimmer.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';

/// Lists the signed-in user's orders in a single, non-paged list: a first-load
/// shimmer, an error state with retry, an empty state and pull-to-refresh.
class MyOrderScreen extends ConsumerStatefulWidget {
  const MyOrderScreen({super.key});

  @override
  ConsumerState<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrderScreen> {
  final ScrollController _scrollController = ScrollController();
  late final GetMyOrdersViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    viewModel = ref.read(getMyOrdersProvider.notifier);
    viewModel.loadMoreState.addListener(_onLoadMoreStateChanged);
  }

  @override
  void dispose() {
    viewModel.loadMoreState.removeListener(_onLoadMoreStateChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Surfaces a load-more failure as an error snackbar, so a paging error is
  /// shown without replacing the already-visible list with a full-screen error.
  void _onLoadMoreStateChanged() {
    final AsyncValue<bool> loadMoreState = viewModel.loadMoreState.value;
    if (loadMoreState.hasError && mounted) {
      ErrorSnackBar.show(context, loadMoreState.error.toString());
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginationModel<OrderModel>> ordersState = ref.watch(
      getMyOrdersProvider,
    );

    return AppWavedView(
      appBarTitle: LangKeys.myOrdersKey.tr(),
      body: ordersState.when(
        loading: () => OrderListViewShimmer(),
        error: (Object error, StackTrace stackTrace) =>
            ServerConnectionErrorWidget(
              message: error.toString(),
              onRetry: viewModel.getOrders,
            ),
        data: (PaginationModel<OrderModel> orders) {
          final List<OrderModel> items = orders.data;

          return AppRefreshIndicator(
            onRefresh: viewModel.getOrders,
            child: items.isEmpty
                ? const NoItemsWidget(isScrollable: true)
                : ValueListenableBuilder<AsyncValue<bool>>(
                    valueListenable: viewModel.loadMoreState,
                    builder:
                        (
                          BuildContext context,
                          AsyncValue<bool> value,
                          Widget? child,
                        ) {
                          final loadingItemsCount = value.isLoading ? 4 : 0;
                          return ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(3),
                            itemCount: items.length + loadingItemsCount,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 20),
                            itemBuilder: (BuildContext context, int index) {
                              if (index > items.length) {
                                return AspectRatio(
                                  aspectRatio: 2,

                                  child: OrderListItemShimmer(),
                                );
                              }
                              return AspectRatio(
                                aspectRatio: 2,
                                child: OrderListItem(orderModel: items[index]),
                              );
                            },
                          );
                        },
                  ),
          );
        },
      ),
    );
  }
}
