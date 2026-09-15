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



class MyOrderScreen extends ConsumerStatefulWidget {
  const MyOrderScreen({super.key});

  @override
  ConsumerState<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrderScreen> {
  final ScrollController _scrollController = ScrollController();
  late final GetMyOrdersViewModel viewModel;





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



                            padding: const EdgeInsets.fromLTRB(3, 57, 3, 3),
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
