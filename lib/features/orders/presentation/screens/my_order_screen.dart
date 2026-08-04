import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item_shimmer.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';

/// Lists the signed-in user's orders. All the paging behaviour — first-page
/// shimmer, error, empty state, infinite scroll and pull-to-refresh — lives in
/// [PaginatedView]; this screen only says what one order looks like.
class MyOrderScreen extends ConsumerWidget {
  const MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GetMyOrdersViewModel viewModel = ref.read(
      getMyOrdersProvider.notifier,
    );

    return AppWavedView(
      appBarTitle: LangKeys.myOrdersKey.tr(),
      body: PaginatedView<OrderModel>(
        provider: getMyOrdersProvider,
        onRefresh: viewModel.loadFirstPage,
        onLoadNextPage: viewModel.loadNextPage,
        layout: const PaginatedListLayout(
          padding: EdgeInsets.all(3),
          separatorBuilder: _separatorBuilder,
        ),
        // Fills the list while the first page loads and trails it while the
        // next page does, so the skeleton always matches the real cards.
        placeholderBuilder: (BuildContext context) => const AspectRatio(
          aspectRatio: 2,
          child: OrderListItemShimmer(),
        ),
        itemBuilder: (BuildContext context, OrderModel order, int index) =>
            AspectRatio(
              aspectRatio: 2,
              child: OrderListItem(orderModel: order),
            ),
      ),
    );
  }

  static Widget _separatorBuilder(BuildContext context, int index) =>
      const SizedBox(height: 20);
}
