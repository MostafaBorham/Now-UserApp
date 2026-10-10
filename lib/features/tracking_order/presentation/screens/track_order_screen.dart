import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/phone_launcher.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/extensions/payment_method_label.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_details/order_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_details_vm.dart';

import '../components/cancel_order_bottom_sheet.dart';
import '../components/courier_section.dart';
import '../components/delivery_details_section.dart';
import '../components/item_information_section.dart';
import '../components/order_timeline_section.dart';
import '../components/track_order_number_header.dart';

/// Track Order screen: order summary, item & delivery details, the courier
/// contact card and the live delivery timeline, with a cancel action.
///
/// Fed by the [orderUuid] handed in by the screen that opened this one (the
/// my-orders list item's "Track Order" button). The uuid keys the
/// [getOrderDetailsProvider] family, so the request starts on first watch and
/// this screen just renders its [AsyncValue] — a shimmer while loading, an
/// error state with retry, and the wired layout on success.
class TrackOrderScreen extends ConsumerStatefulWidget {
  const TrackOrderScreen({super.key, required this.orderUuid});

  final String orderUuid;

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<OrderModel> orderState = ref.watch(
      getOrderDetailsProvider(widget.orderUuid),
    );

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.trackOrderKey.tr(),
        canPop: true,
        hasSupportIcon: true,
        scrollController: _scrollController,
        onSupportTap: () => context.pushNamed(AppRoutes.supportFaqsScreen),
        body: orderState.when(
          loading: () => const OrderDetailsShimmer(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: ref
                    .read(getOrderDetailsProvider(widget.orderUuid).notifier)
                    .getOrderDetails,
              ),
          data: (OrderModel order) {
            final OrderStatus orderStatus = order.lifecycleStatus;
            final String localizedStatus = context.getLocalizedApiText(
              order.orderStatus,
            );
            final String store = context.getLocalizedApiText(order.vendor.name);

            return AppRefreshIndicator(
              onRefresh: ref
                  .read(getOrderDetailsProvider(widget.orderUuid).notifier)
                  .getOrderDetails,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // Owns the top spacing AppWavedView drops when a scroll
                // controller is wired in, so it scrolls up with the content and
                // flattens the wave.
                padding: const EdgeInsets.only(top: 57),
                child: Column(
                  spacing: 16,
                  children: [
                    TrackOrderNumberHeader(
                    orderNumber: order.orderNumber ?? '',
                    status: orderStatus,
                    statusLabel: localizedStatus.isEmpty
                        ? LangKeys.pendingKey.tr()
                        : localizedStatus,
                  ),
                  ItemInformationSection(items: order.items),
                  DeliveryDetailsSection(
                    receiver: order.user.name ?? '',
                    address: order.deliveryAddress ?? '',
                    contact: order.user.phone ?? '',
                    store: store,
                    itemsCount: order.itemsQuantity,
                    paymentMethod: order.paymentMethodLabel,
                    amount: formatMoney(order.totalWithTip),
                  ),
                  // The card shows once a courier is assigned — which can be
                  // well before the order leaves the store — for as long as
                  // the order is on its way.
                  if (orderStatus.isTrackable && order.driver != null)
                    CourierSection(
                      courierName: order.driver?.name ?? '',
                      logoUrl: order.driver?.profileImg ?? '',
                      onCall: () => launchPhoneDialer(order.driver?.phone),
                      onChat: () => context.pushNamed(AppRoutes.supportScreen),
                    ),

                  if (orderStatus.isTrackable)
                    OrderTimelineSection(
                      status: orderStatus,
                      estimatedTime: context.getLocalizedApiDate(
                        apiDateTimeStamp: order.estimatedDeliveryTime,
                      ),
                    ),
                  // The cancel action is only offered while the order can still
                  // be cancelled (before the vendor starts preparing it).
                  if (orderStatus.isCancellable) ...[
                    4.hSpace,
                    PrimaryButton(
                      title: LangKeys.cancelOrderKey.tr(),
                      buttonColor: colors.errorContainer,
                      titleColor: colors.white,
                      onTap: () => CancelOrderBottomSheet.show(
                        context,
                        orderUuid: widget.orderUuid,
                        orderNumber: order.orderNumber ?? '',
                        itemsCount: order.itemsQuantity,
                        amount: formatMoney(order.totalWithTip),
                      ),
                    ),
                    8.hSpace,
                  ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
