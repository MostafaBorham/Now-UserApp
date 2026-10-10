import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/cancel_order_vm.dart';

import 'cancel_sheet_scaffold.dart';
import 'order_canceled_view.dart';

/// The [MainScreen] bottom-nav index of the My Orders tab (Home, Favourites,
/// Cart, **My Orders**, Settings).
const int _myOrdersTabIndex = 3;

/// Confirmation bottom sheet shown when the user taps "Cancel Order" on the
/// Track Order screen. Confirming fires [cancelOrderProvider] for [orderUuid];
/// on success the same sheet swaps its body to the [OrderCanceledView] success
/// state (no second sheet is opened), on failure the sheet stays open and the
/// message is surfaced inline above the actions. (A floating snackbar can't be
/// used here — it renders inside the underlying screen's [Scaffold] and would
/// be hidden behind this sheet.)
class CancelOrderBottomSheet extends ConsumerStatefulWidget {
  const CancelOrderBottomSheet({
    super.key,
    required this.orderUuid,
    required this.orderNumber,
    required this.itemsCount,
    required this.amount,
  });

  final String orderUuid;
  final String orderNumber;
  final int itemsCount;
  final String amount;

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
      ),
    );
  }

  @override
  ConsumerState<CancelOrderBottomSheet> createState() =>
      _CancelOrderBottomSheetState();
}

class _CancelOrderBottomSheetState
    extends ConsumerState<CancelOrderBottomSheet> {
  /// Flips to `true` once the order is cancelled, swapping the confirmation body
  /// for the [OrderCanceledView] success state within this same sheet.
  bool _canceled = false;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // Success state: the order was cancelled, so the sheet keeps its frame and
    // shows the confirmation view in place of the prompt. It's freely
    // dismissible (no PopScope / lock) — the request is already done.
    if (_canceled) {
      return CancelSheetScaffold(
        children: [
          OrderCanceledView(
            // Just dismisses the sheet, returning to the (now cancelled) order.
            onContinueShopping: () => context.pop(),
            // Resets the whole navigation stack to the Main screen and selects
            // the My Orders tab, so nothing from the cancel flow is left behind.
            onViewOrders: () {
              ref.read(mainTabIndexProvider.notifier).state = _myOrdersTabIndex;
              context.goNamed(AppRoutes.mainScreen);
            },
          ),
        ],
      );
    }

    final AsyncValue<void> cancelState = ref.watch(
      cancelOrderProvider(widget.orderUuid),
    );
    final bool isLoading = cancelState.isLoading;
    // On failure `cancelOrder()` leaves the notifier in an error state; surface
    // that message inline (the sheet stays open so the user can retry).
    final String? errorMessage = cancelState.hasError
        ? cancelState.error.toString()
        : null;
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
            orderNumber: widget.orderNumber,
            itemsCount: widget.itemsCount,
            amount: widget.amount,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            _CancelErrorBanner(message: errorMessage),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            title: LangKeys.yesCancelOrderKey.tr(),
            buttonColor: colors.errorContainer,
            titleColor: colors.white,
            buttonPadding: 16,
            isLoading: isLoading,
            onTap: () async {
              final String? error = await ref
                  .read(cancelOrderProvider(widget.orderUuid).notifier)
                  .cancelOrder();

              if (!mounted) return;
              // On failure the notifier holds the error and the banner above
              // renders it; the sheet stays open so the user can retry.
              if (error != null) return;
              setState(() => _canceled = true);
            },
          ),
          const SizedBox(height: 12),
          UnPrimaryAppButton(
            title: LangKeys.keepOrderKey.tr(),
            buttonPadding: 16,
            side: BorderSide(color: colors.neutral200),
            titleColor: colors.black,
            onTap: isLoading ? null : () => context.pop(),
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
                      LangKeys.itemsCountKey.plural(itemsCount),
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

/// Inline error surfaced inside the sheet when cancelling fails, so the message
/// stays visible above the actions (a floating snackbar would sit behind the
/// sheet). [message] may be a [LangKeys] key or a raw server message — it is
/// passed through `.tr()`, which leaves non-key strings untouched.
class _CancelErrorBanner extends StatelessWidget {
  const _CancelErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: colors.errorContainer.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 20, color: colors.onError),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.tr(),
              style: AppTextStyles.style14Regular.copyWith(color: colors.onError),
            ),
          ),
        ],
      ),
    );
  }
}
