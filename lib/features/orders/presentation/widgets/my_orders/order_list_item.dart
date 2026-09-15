import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/extensions/order_status_palette.dart';


class OrderListItem extends ConsumerWidget {
  const OrderListItem({super.key, required this.orderModel});

  final OrderModel orderModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;

    final String statusText = context.getLocalizedApiText(
      orderModel.orderStatus,
    );




    final String deliveredDate = context.getLocalizedApiDate(
      apiDateTimeStamp: context.getLocalizedApiText(orderModel.deliveredAt),
    );
    final String createdDate = context.getLocalizedApiDate(
      apiDateTimeStamp: orderModel.createdAt,
    );

    final OrderStatus status = OrderStatus.fromKey(orderModel.status);





    final String statusDescription = switch (status) {
      AcceptedStatus() => LangKeys.preparingYourOrderKey.tr(),
      OnTheWayStatus() => LangKeys.orderOnTheWayKey.tr(),
      DeliveredStatus() => '${LangKeys.deliveredOnKey.tr()} $deliveredDate',
      CancelledStatus() => '',
      RefundedStatus() => '${LangKeys.refundedOnKey.tr()} $createdDate',
      PendingStatus() ||
      PreparingStatus() ||
      ReadyStatus() ||
      UnknownStatus() => LangKeys.awaitingOrderConfirmationKey.tr(),
    };

    final ({Color background, Color foreground}) statusPalette = status.palette(
      colors,
    );
    final Color statusBackground = statusPalette.background;
    final Color statusColor = statusPalette.foreground;



    final bool showTrackButton = status.isTrackable;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular16,
        boxShadow: [
          BoxShadow(
            color: colors.neutral500.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppBorderRadius.brCircular12,
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: AppCachedNetworkImage(
                    imageUrl: orderModel.vendor.logoUrl ?? '',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            textDirection: TextDirection.ltr,
                            orderModel.orderNumber ?? '',
                            style: AppTextStyles.style18SemiBold.copyWith(
                              color: colors.black,
                            ),
                          ),
                        ),
                        NewPriceWidget(
                          color: colors.primary500Main,
                          price: orderModel.total.toStringAsFixed(2),
                          size: 14,
                        ),
                      ],
                    ),
                    if (statusDescription.isNotEmpty) ...[
                      4.hSpace,
                      AutoSizeText(
                        statusDescription,
                        style: AppTextStyles.style14Regular.copyWith(
                          color: colors.neutral500,
                        ),
                      ),
                    ],
                    10.hSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.neutral500.withValues(alpha: 0.1),
                            borderRadius: AppBorderRadius.brCircular20,
                          ),
                          child: AutoSizeText(
                            '${orderModel.items.length} ${LangKeys.itemsKey.tr()}',
                            style: AppTextStyles.style14Regular.copyWith(
                              color: colors.black,
                            ),
                          ),
                        ),

                        8.wSpace,
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBackground,
                              borderRadius: AppBorderRadius.brCircular20,
                            ),
                            child: AutoSizeText(
                              statusText.isEmpty
                                  ? LangKeys.pendingKey.tr()
                                  : statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.style14Regular.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PrimaryAppButton(
                    title: LangKeys.viewDetailsKey.tr(),
                    buttonPadding: 8,
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.orderDetailsScreen,
                        extra: orderModel.uuid,
                      );
                    },
                  ),
                ),
                if (showTrackButton) ...[
                  12.wSpace,
                  Expanded(
                    child: UnPrimaryButton(
                      title: LangKeys.trackOrderKey.tr(),
                      buttonPadding: 8,
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.trackOrderScreen,
                          extra: orderModel.uuid,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
