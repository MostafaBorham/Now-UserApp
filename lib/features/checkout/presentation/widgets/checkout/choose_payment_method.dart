import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ChoosePaymentMethod extends StatelessWidget {
  const ChoosePaymentMethod({
    super.key,
    this.title = 'Choose Payment Method',
    this.actionLabel = '+ Add Wallet',
    this.onTap,
    this.onAddWallet,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAddWallet;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.style16Medium.copyWith(
                      color: colors.tertiaryContainer,
                    ),
                  ),
                  InkWell(
                    onTap: onAddWallet,
                    child: Text(
                      actionLabel,
                      style: AppTextStyles.style14Regular.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
