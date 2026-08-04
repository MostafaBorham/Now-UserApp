import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';

import 'cancel_sheet_scaffold.dart';
import 'order_canceled_bottom_sheet.dart';

/// Confirmation bottom sheet shown when the user taps "Cancel Order" on the
/// Track Order screen. Confirming opens the [OrderCanceledBottomSheet].
class CancelOrderBottomSheet extends StatelessWidget {
  const CancelOrderBottomSheet({
    super.key,
    required this.onConfirm,
    required this.onKeep,
    this.orderNumber = '#ORD-284917',
    this.itemsCount = 3,
    this.amount = '20.00',
  });

  final VoidCallback onConfirm;
  final VoidCallback onKeep;
  final String orderNumber;
  final int itemsCount;
  final String amount;

  /// Presents the sheet; confirming closes it and opens the success sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CancelOrderBottomSheet(
        onKeep: () => context.pop(),
        onConfirm: () {
          context.pop();
          OrderCanceledBottomSheet.show(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return CancelSheetScaffold(
      children: [
        const SizedBox(height: 8),
        Center(child: Assets.media.images.svg.cancel.svg()),
        const SizedBox(height: 24),
        Text(
          LangKeys.areYouSureCancelKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style20Bold.copyWith(
            color: colors.onSecondary,
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
          titleColor: colors.onPrimary,
          buttonPadding: 16,
          onTap: onConfirm,
        ),
        const SizedBox(height: 12),
        UnPrimaryButton(
          title: LangKeys.keepOrderKey.tr(),
          buttonPadding: 16,
          borderColor: colors.surfaceContainerLow,
          onTap: onKeep,
        ),
        const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tileBackground,
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
                    color: colors.onSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '$itemsCount ${LangKeys.itemsKey.tr()}',
                      style: AppTextStyles.style14Regular.copyWith(color: muted),
                    ),
                    const SizedBox(width: 10),
                    Assets.media.images.svg.realSaudiCurrency.svg(
                      width: 13,
                      height: 13,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(muted, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      amount,
                      style: AppTextStyles.style14Regular.copyWith(color: muted),
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
