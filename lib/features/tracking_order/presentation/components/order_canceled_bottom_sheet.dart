import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_button.dart';

import 'cancel_sheet_scaffold.dart';

/// Success bottom sheet shown after an order is canceled: confirms the refund
/// and offers to keep shopping or review orders.
class OrderCanceledBottomSheet extends StatelessWidget {
  const OrderCanceledBottomSheet({
    super.key,
    required this.onContinueShopping,
    required this.onViewOrders,
  });

  final VoidCallback onContinueShopping;
  final VoidCallback onViewOrders;

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => OrderCanceledBottomSheet(
        onContinueShopping: () => Navigator.pop(context),
        onViewOrders: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return CancelSheetScaffold(
      children: [
        const SizedBox(height: 8),
        Center(child: Assets.media.images.svg.checkout.orderDone.svg()),
        const SizedBox(height: 24),
        Text(
          LangKeys.orderCanceledTitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style20Bold.copyWith(
            color: colors.onSecondary,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          LangKeys.orderCanceledSubtitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style14Regular.copyWith(
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 32),
        PrimaryAppButton(
          title: LangKeys.continueShoppingKey.tr(),
          buttonPadding: 16,
          onTap: onContinueShopping,
        ),
        const SizedBox(height: 12),
        UnPrimaryButton(
          title: LangKeys.viewOrdersKey.tr(),
          buttonPadding: 16,
          borderColor: TrackingOrderColors.border2,
          onTap: onViewOrders,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
