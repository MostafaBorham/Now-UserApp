import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
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
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_details/order_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_details_vm.dart';

import '../components/cancel_order_bottom_sheet.dart';
import '../components/courier_section.dart';
import '../components/delivery_details_section.dart';
import '../components/item_information_section.dart';
import '../components/order_timeline_section.dart';
import '../components/track_order_number_header.dart';









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
            final OrderStatus orderStatus = OrderStatus.fromKey(order.status);
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
                    itemsCount: order.items.length,
                    paymentMethod: order.paymentMethod ?? '',
                    amount: order.total.toStringAsFixed(2),
                  ),



                  if (orderStatus is OnTheWayStatus && order.driver != null)
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


                  if (orderStatus.isCancellable) ...[
                    4.hSpace,
                    PrimaryButton(
                      title: LangKeys.cancelOrderKey.tr(),
                      buttonColor: colors.errorContainer,
                      titleColor: colors.white,
                      buttonPadding: 16,
                      onTap: () => CancelOrderBottomSheet.show(
                        context,
                        orderUuid: widget.orderUuid,
                        orderNumber: order.orderNumber ?? '',
                        itemsCount: order.items.length,
                        amount: order.total.toStringAsFixed(2),
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
