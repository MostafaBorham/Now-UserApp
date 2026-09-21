import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';
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

  /// Guards the one-shot auto-retry: the app pre-fetches orders on session
  /// start, and if that failed the screen opens on a stale error state. We
  /// silently retry once (showing the shimmer, not the error widget) and only
  /// surface the error widget if that retry also fails.
  bool _didAutoRetry = false;

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


  void _onLoadMoreStateChanged() {
    final AsyncValue<bool> loadMoreState = viewModel.loadMoreState.value;
    if (loadMoreState.hasError && mounted) {
      AppToast.showError(context, loadMoreState.error.toString());
    }
  }

  void _onScroll() {
    // Only load more once the very end of the list is fully visible on screen.
    // `extentAfter` is the amount of scrollable content still hidden below the
    // viewport, so it reaches 0 exactly when no part of the list tail is
    // clipped off-screen — unlike a fixed pixel threshold, which re-fires while
    // the user is still near (but not at) the bottom with the tail cut off.
    if (_scrollController.position.extentAfter <= 0) {
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
      scrollController: _scrollController,
      body: ordersState.when(
        loading: () => OrderListViewShimmer(),
        error: (Object error, StackTrace stackTrace) {
          // First time we land on an error state (a stale pre-fetch failure),
          // show the shimmer and silently retry once — after this frame, since
          // a provider cannot be modified during build.
          if (!_didAutoRetry) {
            _didAutoRetry = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) viewModel.getOrders();
            });
            return OrderListViewShimmer();
          }
          return ServerConnectionErrorWidget(
            message: error.toString(),
            onRetry: viewModel.getOrders,
          );
        },
        data: (PaginationModel<OrderModel> orders) {
          final List<OrderModel> items = orders.data;

          return AppRefreshIndicator(
            onRefresh: viewModel.getOrders,
            child: items.isEmpty
                ? const NoResultsWidget(isScrollable: true)
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
                            // Owns the top spacing AppWavedView drops when a
                            // scroll controller is wired in, so it scrolls up
                            // with the content and flattens the wave. The bottom
                            // clears the bar the main screen draws behind the
                            // body (extendBody), so the last order isn't hidden.
                            padding: EdgeInsets.fromLTRB(
                              3,
                              57,
                              3,
                              3 + MediaQuery.paddingOf(context).bottom,
                            ),
                            itemCount: items.length + loadingItemsCount,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(height: 20),
                            itemBuilder: (BuildContext context, int index) {
                              if (index >= items.length) {
                                return AspectRatio(
                                  aspectRatio: 2,

                                  child: OrderListItemShimmer(),
                                );
                              }
                              return OrderListItem(orderModel: items[index]);
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
