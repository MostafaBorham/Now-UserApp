import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(getMyOrdersProvider).hasValue) {
        ref.read(getMyOrdersProvider.notifier).loadOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GetMyOrdersViewModel viewModel = ref.read(
      getMyOrdersProvider.notifier,
    );
    final AsyncValue<PaginationModel<OrderModel>> ordersState = ref.watch(
      getMyOrdersProvider,
    );

    return AppWavedView(
      appBarTitle: LangKeys.myOrdersKey.tr(),
      body: ordersState.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(3),
          itemCount: 4,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 20),
          itemBuilder: (BuildContext context, int index) =>
              const AspectRatio(aspectRatio: 2, child: OrderListItemShimmer()),
        ),
        error: (Object error, StackTrace stackTrace) =>
            ServerConnectionErrorWidget(
              message: error.toString(),
              onRetry: viewModel.loadFirstPage,
            ),
        data: (PaginationModel<OrderModel> orders) {
          final List<OrderModel> items = orders.data;

          return AppRefreshIndicator(
            onRefresh: viewModel.loadFirstPage,
            child: items.isEmpty
                ? const NoItemsWidget(isScrollable: true)
                : ListView.separated(
                    padding: const EdgeInsets.all(3),
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (BuildContext context, int index) =>
                        AspectRatio(
                          aspectRatio: 2,
                          child: OrderListItem(orderModel: items[index]),
                        ),
                  ),
          );
        },
      ),
    );
  }
}