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
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_results_widget.dart';

/// The signed-in user's orders: infinite scroll, pull-to-refresh, and the
/// first-page shimmer, error and empty states, all from [PaginatedView].
///
/// The list is loaded at sign-in and kept, so every time the tab opens it is
/// refreshed quietly — the orders stay on screen and the new statuses land on
/// them. That also retries a sign-in load that failed.
class MyOrderScreen extends ConsumerStatefulWidget {
  const MyOrderScreen({super.key});

  @override
  ConsumerState<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends ConsumerState<MyOrderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // After this frame: a provider can't be modified while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(getMyOrdersProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GetMyOrdersViewModel viewModel = ref.read(
      getMyOrdersProvider.notifier,
    );

    return AppWavedView(
      appBarTitle: LangKeys.myOrdersKey.tr(),
      canPop: false,
      scrollController: _scrollController,
      body: PaginatedView<OrderModel>(
        provider: getMyOrdersProvider,
        scrollController: _scrollController,
        onRefresh: viewModel.loadFirstPage,
        onLoadNextPage: viewModel.loadNextPage,
        // Owns the top spacing AppWavedView drops when a scroll controller is
        // wired in, so it scrolls up with the content.
        // The bottom clears the bar the main screen draws behind the body
        // (extendBody), so the last order isn't hidden.
        layout: PaginatedListLayout(
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 20),
          padding: EdgeInsets.fromLTRB(
            3,
            57,
            3,
            3 + MediaQuery.paddingOf(context).bottom,
          ),
        ),
        emptyBuilder: (BuildContext context) => NoResultsWidget(
          isScrollable: true,
          emptyMessage: LangKeys.noOrdersYetKey.tr(),
        ),
        placeholderBuilder: (_) => const AspectRatio(
          aspectRatio: 2,
          child: OrderListItemShimmer(),
        ),
        itemBuilder: (BuildContext context, OrderModel order, int index) =>
            OrderListItem(orderModel: order),
      ),
    );
  }
}
