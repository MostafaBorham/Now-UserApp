import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
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
class TrackOrderScreen extends ConsumerWidget {
  const TrackOrderScreen({super.key, required this.orderUuid});

  final String orderUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<OrderModel> orderState = ref.watch(
      getOrderDetailsProvider(orderUuid),
    );

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.trackOrderKey.tr(),
        canPop: true,
        hasSupportIcon: true,
        onSupportTap: () {},
        body: orderState.when(
          loading: () => const OrderDetailsShimmer(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: ref
                    .read(getOrderDetailsProvider(orderUuid).notifier)
                    .getOrderDetails,
              ),
          data: (OrderModel order) {
            final String localizedStatus = context.getLocalizedApiText(
              order.orderStatus,
            );
            final String store = context.getLocalizedApiText(order.vendor.name);

            return SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  TrackOrderNumberHeader(
                    orderNumber: order.orderNumber ?? '',
                    status: localizedStatus.isEmpty
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
                  CourierSection(courierName: store),
                  OrderTimelineSection(
                    status: OrderStatus.fromKey(order.status),
                    estimatedTime: context.getLocalizedApiDate(
                      apiDateTimeStamp: order.estimatedDeliveryTime,
                    ),
                  ),
                  4.hSpace,
                  PrimaryButton(
                    title: LangKeys.cancelOrderKey.tr(),
                    buttonColor: colors.errorContainer,
                    titleColor: colors.white,
                    buttonPadding: 16,
                    onTap: () => CancelOrderBottomSheet.show(context),
                  ),
                  8.hSpace,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
