import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/extensions/order_status_palette.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/extensions/payment_method_label.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_details/order_details_shimmer.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_details/order_invoice_row.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/order_rating_view.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_details_vm.dart';

/// Full details of a single placed order, fetched by the [orderUuid] handed in
/// by the screen that opened this one (the my-orders list item). The uuid keys
/// the [getOrderDetailsProvider] family, so the request starts on first watch
/// and this screen just renders its [AsyncValue] — a shimmer while loading, an
/// error state with retry, and the wired layout on success.
class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderUuid});

  final String orderUuid;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final LinearGradient screenGradient = LinearGradient(
      begin: AlignmentDirectional.centerStart,
      end: AlignmentDirectional.centerEnd,
      colors: [colors.primary100.withValues(alpha: 0.3), colors.secondary100],
    );

    final AsyncValue<OrderModel> orderState = ref.watch(
      getOrderDetailsProvider(widget.orderUuid),
    );

    return Scaffold(
      body: AppWavedView(
        appBarTitle: LangKeys.orderDetailsKey.tr(),
        canPop: true,
        hasSupportIcon: orderState.valueOrNull?.canContactSupport ?? false,
        onSupportTap: () => context.pushNamed(AppRoutes.supportFaqsScreen),
        scrollController: _scrollController,
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
            final String orderNumber = order.orderNumber ?? '';
            final String localizedStatus = context.getLocalizedApiText(
              order.orderStatus,
            );
            // Same status chip as the my-orders list item: colors from the
            // shared palette and an empty label falls back to "pending".
            final OrderStatus status = order.lifecycleStatus;
            final ({Color background, Color foreground}) statusPalette = status
                .palette(colors);
            final String statusText = localizedStatus.isEmpty
                ? LangKeys.pendingKey.tr()
                : localizedStatus;
            final String orderDate = context.getLocalizedApiDate(
              apiDateTimeStamp: order.createdAt,
            );
            final String paymentMethodLabel = order.paymentMethodLabel;

            return AppRefreshIndicator(
              onRefresh: ref
                  .read(getOrderDetailsProvider(widget.orderUuid).notifier)
                  .getOrderDetails,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // Owns the top spacing AppWavedView drops when a scroll
                // controller is wired in, so it scrolls up with the content.
                padding: const EdgeInsets.only(top: 57),
                child: Column(
                  spacing: 15,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: screenGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Assets.media.images.svg.orderIcon.svg(
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  colors.tertiaryContainer,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LangKeys.orderNumberKey.tr(),
                                  style: AppTextStyles.style12Medium.copyWith(
                                    color: colors.neutral500,
                                  ),
                                ),
                                Text(
                                  orderNumber,
                                  overflow: TextOverflow.visible,
                                  style: AppTextStyles.style18SemiBold.copyWith(
                                    color: colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusPalette.background,
                                  borderRadius: AppBorderRadius.brCircular20,
                                ),
                                child: Text(
                                  statusText,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                  style: AppTextStyles.style14Regular.copyWith(
                                    color: statusPalette.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: screenGradient,
                        borderRadius: AppBorderRadius.brCircular12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LangKeys.generalInformationKey.tr(),
                            style: AppTextStyles.style16SemiBold.copyWith(
                              color: colors.black,
                            ),
                          ),
                          12.hSpace,
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.white,
                              borderRadius: AppBorderRadius.brCircular8,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        LangKeys.orderNumberKey.tr(),
                                        style: AppTextStyles.style14Regular
                                            .copyWith(color: colors.neutral500),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        orderNumber,
                                        textAlign: TextAlign.end,

                                        overflow: TextOverflow.visible,
                                        style: AppTextStyles.style14Medium
                                            .copyWith(color: colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                16.hSpace,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        LangKeys.orderDateKey.tr(),
                                        style: AppTextStyles.style14Regular
                                            .copyWith(color: colors.neutral500),
                                      ),
                                    ),
                                    Text(
                                      orderDate,
                                      style: AppTextStyles.style14Medium
                                          .copyWith(color: colors.black),
                                    ),
                                  ],
                                ),
                                16.hSpace,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        LangKeys.paymentMethodKey.tr(),
                                        style: AppTextStyles.style14Regular
                                            .copyWith(color: colors.neutral500),
                                      ),
                                    ),
                                    Text(
                                      paymentMethodLabel,
                                      style: AppTextStyles.style14Medium
                                          .copyWith(
                                            color: colors.primary500Main,
                                          ),
                                    ),
                                  ],
                                ),
                                16.hSpace,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        LangKeys.numberOfItemsKey.tr(),
                                        style: AppTextStyles.style14Regular
                                            .copyWith(color: colors.neutral500),
                                      ),
                                    ),
                                    Text(
                                      '${order.itemsQuantity}',
                                      style: AppTextStyles.style14Medium
                                          .copyWith(
                                            color: colors.primary500Main,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Rating is one-shot in the app: once anything was
                          // rated the order shows what was submitted, even with
                          // targets left open. Thank the shopper only for a
                          // real rating, and offer one only while it can still
                          // be sent.
                          if (status.isRateable)
                            if (order.rating.isRated) ...[
                              12.hSpace,
                              OrderRatingView(rating: order.rating),
                            ] else if (order.rating.canRate) ...[
                              12.hSpace,
                              PrimaryAppButton(
                                title: LangKeys.rateOrderKey.tr(),
                                onTap: () => context.pushNamed(
                                  AppRoutes.orderRatingScreen,
                                  extra: order,
                                ),
                              ),
                            ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: screenGradient,
                        borderRadius: AppBorderRadius.brCircular12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            LangKeys.itemInformationKey.tr(),
                            style: AppTextStyles.style16SemiBold.copyWith(
                              color: colors.black,
                            ),
                          ),
                          for (final ProductModel item in order.items)
                            _OrderLineRow(item: item),
                          // Refused by the vendor: kept visible so the
                          // customer knows it didn't come, but out of every
                          // total.
                          for (final ProductModel item
                              in order.unavailableItems)
                            _OrderLineRow(item: item, unavailable: true),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: screenGradient,
                        borderRadius: AppBorderRadius.brCircular12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LangKeys.deliveryDetailsKey.tr(),
                            style: AppTextStyles.style16SemiBold.copyWith(
                              color: colors.black,
                            ),
                          ),
                          12.hSpace,
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.white,
                              borderRadius: AppBorderRadius.brCircular8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: colors.primary500Main,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Assets
                                            .media
                                            .images
                                            .svg
                                            .marketIcon
                                            .svg(
                                              width: 20,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                colors.white,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                      ),
                                    ),
                                    12.wSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            LangKeys.fromKey.tr(),
                                            style: AppTextStyles.style12Medium
                                                .copyWith(color: colors.black),
                                          ),
                                          2.hSpace,
                                          Text(
                                            context.getLocalizedApiText(
                                              order.vendor.name,
                                            ),
                                            style: AppTextStyles.style14Medium
                                                .copyWith(
                                                  color: colors.neutral500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 22),
                                    Container(
                                      width: 2,
                                      height: 15,
                                      color: colors.neutral500,
                                      margin: EdgeInsetsDirectional.symmetric(
                                        vertical: 5,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: colors.onSecondaryFixedVariant,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Assets
                                            .media
                                            .images
                                            .svg
                                            .locationIcon
                                            .svg(
                                              width: 20,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                colors.black,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                      ),
                                    ),
                                    12.wSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            LangKeys.toKey.tr(),
                                            style: AppTextStyles.style12Medium
                                                .copyWith(color: colors.black),
                                          ),
                                          2.hSpace,
                                          // Detail page: show the full delivery
                                          // address — no line clamp / ellipsis.
                                          // The app text styles bake in ellipsis,
                                          // so overflow is forced visible to wrap.
                                          Text(
                                            order.deliveryAddress ?? '',
                                            overflow: TextOverflow.visible,
                                            style: AppTextStyles.style14Medium
                                                .copyWith(
                                                  color: colors.neutral500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: screenGradient,
                        borderRadius: AppBorderRadius.brCircular12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LangKeys.paymentMethodKey.tr(),
                            style: AppTextStyles.style16SemiBold.copyWith(
                              color: colors.black,
                            ),
                          ),
                          12.hSpace,
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.white,
                              borderRadius: AppBorderRadius.brCircular8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: colors.primary500Main.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Assets.media.images.svg.wallet.svg(
                                      width: 22,
                                      height: 22,
                                      colorFilter: ColorFilter.mode(
                                        colors.primary500Main,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AutoSizeText(
                                        paymentMethodLabel,
                                        style: AppTextStyles.style16Medium
                                            .copyWith(color: colors.black),
                                      ),
                                      NewPriceWidget(
                                        color: colors.neutral500,
                                        size: 14,
                                        fontWeight: FontWeight.w400,
                                        price: order.totalWithTip
                                            .toStringAsFixed(2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: screenGradient,
                        borderRadius: AppBorderRadius.brCircular12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            LangKeys.invoiceSummaryKey.tr(),
                            style: AppTextStyles.style16SemiBold.copyWith(
                              color: colors.black,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.white,
                              borderRadius: AppBorderRadius.brCircular8,
                            ),
                            child: Column(
                              spacing: 10,
                              children: [
                                OrderInvoiceRow(
                                  label: LangKeys.subtotalKey.tr(),
                                  value: order.subtotal,
                                  valueColor: colors.black,
                                ),
                                OrderInvoiceRow(
                                  label: LangKeys.vatKey.tr(),
                                  value: order.tax,
                                  valueColor: colors.black,
                                ),
                                OrderInvoiceRow(
                                  label: LangKeys.deliveryFeesKey.tr(),
                                  value: order.deliveryFee,
                                  valueColor: colors.black,
                                ),
                                // The tip is charged but untaxed, so it is no
                                // part of the rows above; Total adds it.
                                if (order.driverTip > 0)
                                  OrderInvoiceRow(
                                    label: LangKeys.driverTipKey.tr(),
                                    value: order.driverTip,
                                    valueColor: colors.black,
                                  ),
                                // Only surfaced when there is an actual discount.
                                if (order.couponDiscount != 0)
                                  OrderInvoiceRow(
                                    label: LangKeys.discountLabelKey.tr(),
                                    value: order.couponDiscount,
                                    valueColor: colors.onError,
                                  ),
                                if (order.voucherDiscount > 0)
                                  OrderInvoiceRow(
                                    label:
                                        '${LangKeys.purchaseVoucherKey.tr()} (${order.voucherCode ?? ''})',
                                    value: order.voucherDiscount,
                                    valueColor: colors.onError,
                                  ),
                                Divider(
                                  color: colors.neutral400,
                                  thickness: 0.5,
                                ),
                                OrderInvoiceRow(
                                  label: LangKeys.totalKey.tr(),
                                  value: order.totalWithTip,
                                  valueColor: colors.primary500Main,
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                          if (status.hasInvoice &&
                              (order.invoicePdfUrl ?? '').isNotEmpty)
                            PrimaryAppButton(
                              title: LangKeys.printInvoiceKey.tr(),
                              onTap: () => context.pushNamed(
                                AppRoutes.invoiceViewerScreen,
                                extra: order.invoicePdfUrl,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // The complaint flow only applies once the order has been
                    // delivered — hide the button for every other status. The
                    // backend takes one complaint per order, so once one is on
                    // file the button says so instead of opening the form.
                    if (status is DeliveredStatus && order.hasComplaint)
                      PrimaryButton(
                        title: LangKeys.complaintAlreadySubmittedKey.tr(),
                        buttonColor: colors.neutral300,
                        titleColor: colors.neutral500,
                      )
                    else if (status is DeliveredStatus)
                      PrimaryButton(
                        title: LangKeys.submitAComplaintKey.tr(),
                        onTap: () => context.pushNamed(
                          AppRoutes.fileComplaintScreen,
                          extra: order,
                        ),
                      ),
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

/// One line of the order, on its own white card: picture, name, the price paid
/// per unit and the quantity. An [unavailable] line — refused by the vendor,
/// never delivered, charged nothing — is dimmed and says so in place of its
/// price.
class _OrderLineRow extends StatelessWidget {
  const _OrderLineRow({required this.item, this.unavailable = false});

  final ProductModel item;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: AppBorderRadius.brCircular8,
      ),
      // Inside the card, so only the content dims and the card stays white.
      child: Opacity(
        opacity: unavailable ? 0.5 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            ClipRRect(
              borderRadius: AppBorderRadius.brCircular12,
              child: AppCachedNetworkImage(
                imageUrl: item.images?.firstOrNull ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    context.getLocalizedApiText(item.name),
                    style: AppTextStyles.style16Medium.copyWith(
                      color: colors.black,
                    ),
                  ),
                  if (unavailable)
                    Text(
                      LangKeys.outOfStockKey.tr(),
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.onError,
                      ),
                    )
                  else
                    NewPriceWidget(
                      color: colors.black,
                      size: 14,
                      fontWeight: FontWeight.w400,
                      price: (item.price ?? 0).toStringAsFixed(2),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: AutoSizeText(
                'x${item.quantity ?? 0}',
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
