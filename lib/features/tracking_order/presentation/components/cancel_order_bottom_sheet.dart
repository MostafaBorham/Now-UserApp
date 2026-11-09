import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/main/presentation/controllers/main_tab_index_provider.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/cancel_order_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_details_vm.dart';

import 'cancel_reasons_section.dart';
import 'cancel_sheet_scaffold.dart';
import 'order_canceled_view.dart';

const int _myOrdersTabIndex = 3;
const int _otherReasonMinLength = 10;
const double _maxHeightFactor = 0.75;

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
      useSafeArea: true,
      // Drag dismissal bypasses PopScope while cancellation is in flight.
      enableDrag: false,
      showDragHandle: false,
      backgroundColor: context.colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
          ),
          child: CancelOrderBottomSheet(
            orderUuid: orderUuid,
            orderNumber: orderNumber,
            itemsCount: itemsCount,
            amount: amount,
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<CancelOrderBottomSheet> createState() =>
      _CancelOrderBottomSheetState();
}

class _CancelOrderBottomSheetState
    extends ConsumerState<CancelOrderBottomSheet> {
  final TextEditingController _otherReasonController = TextEditingController();
  CancelOrderReason? _selectedReason;
  bool _canceled = false;

  bool _canCancel(String otherReason) =>
      _selectedReason != null &&
      (_selectedReason != CancelOrderReason.other ||
          otherReason.trim().characters.length >= _otherReasonMinLength);

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _dismiss() => Navigator.of(context).pop();

  Future<void> _cancelOrder() async {
    final provider = cancelOrderProvider(widget.orderUuid);
    if (_canceled ||
        ref.read(provider).isLoading ||
        !_canCancel(_otherReasonController.text)) {
      return;
    }

    FocusScope.of(context).unfocus();
    final String reason = _selectedReason == CancelOrderReason.other
        ? _otherReasonController.text.trim()
        : _selectedReason!.labelKey.tr();
    final String? error = await ref
        .read(provider.notifier)
        .cancelOrder(reason: reason);
    if (!mounted) return;

    if (error == LangKeys.orderCannotBeCancelledKey) {
      // The order may have moved to a status that no longer allows cancellation.
      ref
          .read(getOrderDetailsProvider(widget.orderUuid).notifier)
          .getOrderDetails();
    }
    if (error == null) setState(() => _canceled = true);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    if (_canceled) {
      return CancelSheetScaffold(
        expand: true,
        body: const OrderCanceledView(),
        footer: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              PrimaryAppButton(
                title: LangKeys.continueShoppingKey.tr(),
                onTap: _dismiss,
              ),
              UnPrimaryAppButton(
                title: LangKeys.viewOrdersKey.tr(),
                side: BorderSide(color: colors.neutral200),
                titleColor: colors.black,
                onTap: () {
                  ref.read(mainTabIndexProvider.notifier).state =
                      _myOrdersTabIndex;
                  context.goNamed(AppRoutes.mainScreen);
                },
              ),
            ],
          ),
        ),
      );
    }

    final AsyncValue<void> cancelState = ref.watch(
      cancelOrderProvider(widget.orderUuid),
    );
    final bool isLoading = cancelState.isLoading;
    final String? errorMessage = cancelState.hasError
        ? cancelState.error.toString()
        : null;
    return PopScope(
      canPop: !isLoading,
      child: CancelSheetScaffold(
        canClose: !isLoading,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            const _CancelWarningHeader(),
            _OrderSummaryCard(
              orderNumber: widget.orderNumber,
              itemsCount: widget.itemsCount,
              amount: widget.amount,
            ),
            IgnorePointer(
              ignoring: isLoading,
              child: CancelReasonsSection(
                selectedReason: _selectedReason,
                otherReasonController: _otherReasonController,
                onReasonSelected: (CancelOrderReason reason) {
                  setState(() => _selectedReason = reason);
                },
              ),
            ),
          ],
        ),
        footer: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.dividerLight)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              if (errorMessage != null)
                _CancelErrorBanner(message: errorMessage),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: UnPrimaryAppButton(
                      title: LangKeys.keepOrderKey.tr(),
                      compact: true,
                      backgroundColor: colors.primaryFixed,
                      side: BorderSide(color: colors.neutral200),
                      titleColor: colors.neutral1200,
                      titleStyle: AppTextStyles.style16Medium,
                      onTap: isLoading ? null : _dismiss,
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _otherReasonController,
                      builder: (context, value, child) {
                        final bool canCancel = _canCancel(value.text);
                        return PrimaryAppButton(
                          title: LangKeys.yesCancelOrderKey.tr(),
                          compact: true,
                          buttonColor: colors.errorContainer.withValues(
                            alpha: canCancel || isLoading ? 1 : 0.4,
                          ),
                          titleStyle: AppTextStyles.style16Medium,
                          isLoading: isLoading,
                          onTap: canCancel ? _cancelOrder : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelWarningHeader extends StatelessWidget {
  const _CancelWarningHeader();

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      children: [
        Assets.media.images.svg.cancel.svg(),
        const SizedBox(height: 8),
        Text(
          LangKeys.areYouSureCancelKey.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.style20Bold.copyWith(
            color: colors.black,
            fontSize: 22,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            LangKeys.cancelOrderWarningKey.tr(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: AppTextStyles.style14Regular.copyWith(
              color: const Color(0xFF686868),
              height: 1.625,
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colors.onTertiaryContainer,
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: colors.dividerLight),
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
                const SizedBox(height: 2),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      LangKeys.itemsCountKey.plural(itemsCount),
                      style: AppTextStyles.style12Medium.copyWith(color: muted),
                    ),
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
              style: AppTextStyles.style14Regular.copyWith(
                color: colors.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
