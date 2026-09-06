import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/cancel_order_vm.dart';

import 'cancel_sheet_scaffold.dart';
import 'order_canceled_bottom_sheet.dart';

/// Confirmation bottom sheet shown when the user taps "Cancel Order" on the
/// Track Order screen. Confirming fires [cancelOrderProvider] for [orderUuid];
/// on success the sheet closes and the [OrderCanceledBottomSheet] opens, on
/// failure the message is surfaced in a snackbar and the sheet stays put.
class CancelOrderBottomSheet extends ConsumerWidget {
  const CancelOrderBottomSheet({
    super.key,
    required this.orderUuid,
    required this.orderNumber,
    required this.itemsCount,
    required this.amount,
    required this.onKeep,
    required this.onCanceled,
  });

  final String orderUuid;
  final String orderNumber;
  final int itemsCount;
  final String amount;

  /// Dismisses the sheet without cancelling (the "Keep Order" action).
  final VoidCallback onKeep;

  /// Invoked after the order is successfully cancelled — closes this sheet and
  /// opens the success sheet. Uses the presenting context, so it stays valid
  /// once this sheet pops.
  final VoidCallback onCanceled;

  /// Presents the sheet, wired to the order it belongs to.
  static Future<void> show(
    BuildContext context, {
    required String orderUuid,
    required String orderNumber,
    required int itemsCount,
    required String amount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CancelOrderBottomSheet(
        orderUuid: orderUuid,
        orderNumber: orderNumber,
        itemsCount: itemsCount,
        amount: amount,
        onKeep: () => context.pop(),
        onCanceled: () {
          context.pop();
          OrderCanceledBottomSheet.show(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final bool isLoading = ref.watch(
      cancelOrderProvider(
        orderUuid,
      ).select((AsyncValue<void> state) => state.isLoading),
    );
    // While the cancel request is in flight the sheet is fully locked: back
    // gesture / button, drag-down and scrim tap are blocked by PopScope, the
    // close button by [canClose], and the action buttons disable themselves.
    return PopScope(
      canPop: !isLoading,
      child: CancelSheetScaffold(
        canClose: !isLoading,
        children: [
          const SizedBox(height: 8),
          Center(child: Assets.media.images.svg.cancel.svg()),
          const SizedBox(height: 24),
          Text(
            LangKeys.areYouSureCancelKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.style20Bold.copyWith(
              color: colors.black,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LangKeys.cancelOrderWarningKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 3,
            style: AppTextStyles.style14Regular.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          _OrderSummaryCard(
            orderNumber: orderNumber,
            itemsCount: itemsCount,
            amount: amount,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            title: LangKeys.yesCancelOrderKey.tr(),
            buttonColor: colors.errorContainer,
            titleColor: colors.white,
            buttonPadding: 16,
            isLoading: isLoading,
            onTap: () async {
              final String? error = await ref
                  .read(cancelOrderProvider(orderUuid).notifier)
                  .cancelOrder();

              if (error != null) {
                if (context.mounted) ErrorSnackBar.show(context, error);
                return;
              }
              onCanceled();
            },
          ),
          const SizedBox(height: 12),
          UnPrimaryButton(
            title: LangKeys.keepOrderKey.tr(),
            buttonPadding: 16,
            borderColor: colors.neutral200,
            onTap: isLoading ? null : onKeep,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// The order at a glance (number, item count and total) with its package glyph.
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.orderNumber,
    required this.itemsCount,
    required this.amount,
  });

  final String orderNumber;
  final int itemsCount;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    const Color muted = Color(0xFF888888);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onTertiaryContainer,
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${LangKeys.orderKey.tr()} $orderNumber',
                  style: AppTextStyles.style14Bold.copyWith(
                    color: colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '$itemsCount ${LangKeys.itemsKey.tr()}',
                      style: AppTextStyles.style14Regular.copyWith(
                        color: muted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    NewPriceWidget(
                      color: muted,
                      size: 14,
                      fontWeight: FontWeight.w400,
                      price: amount,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Assets.media.images.svg.order2.svg(width: 50, height: 50),
        ],
      ),
    );
  }
}
