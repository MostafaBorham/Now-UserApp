import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart' as loc;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// One placed order in the my-orders list, rendered from [orderModel].
class OrderListItem extends ConsumerWidget {
  const OrderListItem({super.key, required this.orderModel});

  final OrderModel orderModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;

    final String statusText = context.getLocalizedApiText(
      orderModel.orderStatus,
    );

    // Dates the status descriptions embed: delivered shows when the order
    // arrived (`delivered_at`, a localized map), refunded shows when it was
    // placed (`created_at`). formatLocalizedDate parses the raw ISO-8601 value.
    final String deliveredDate = context.getLocalizedApiDate(
      apiDateTimeStamp: context.getLocalizedApiText(orderModel.deliveredAt),
    );
    final String createdDate = context.getLocalizedApiDate(
      apiDateTimeStamp: orderModel.createdAt,
    );

    final (String statusDescription, Color statusBackground, Color statusColor) =
        switch (orderModel.status) {
          'pending' => (
            LangKeys.awaitingOrderConfirmationKey.tr(),
            colors.tertiaryFixed,
            colors.onErrorContainer,
          ),
          'accepted' => (
            LangKeys.preparingYourOrderKey.tr(),
            colors.sky500.withValues(alpha: 0.15),
            colors.sky500,
          ),
          'on_the_way' => (
            LangKeys.orderOnTheWayKey.tr(),
            colors.tertiaryFixed,
            colors.orange500,
          ),
          'delivered' => (
            '${LangKeys.deliveredOnKey.tr()} $deliveredDate',
            colors.primary100,
            colors.primary500Main,
          ),
          'cancelled' => (
            '',
            colors.onError.withValues(alpha: 0.15),
            colors.onError,
          ),
          'refunded' => (
            '${LangKeys.refundedOnKey.tr()} $createdDate',
            colors.orange100,
            colors.deepOrange400,
          ),
          _ => (
            LangKeys.awaitingOrderConfirmationKey.tr(),
            colors.tertiaryFixed,
            colors.onErrorContainer,
          ),
        };

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
                            '#${orderModel.orderNumber ?? ''}',
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
                      context.pushNamed(AppRoutes.orderDetailsScreen);
                    },
                  ),
                ),
                12.wSpace,
                Expanded(
                  child: UnPrimaryButton(
                    title: LangKeys.trackOrderKey.tr(),
                    buttonPadding: 8,
                    onTap: () {
                      context.pushNamed(AppRoutes.trackOrderScreen);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
