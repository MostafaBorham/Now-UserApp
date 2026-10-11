import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ChoosePaymentMethod extends StatelessWidget {
  const ChoosePaymentMethod({
    super.key,
    this.title,
    this.actionLabel,
    this.onTap,
  });

  final String? title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String resolvedTitle = title ?? LangKeys.choosePaymentMethodKey.tr();
    // It opens the add-card screen, so it says so (BUG-046).
    final String resolvedActionLabel = actionLabel ?? LangKeys.addCardKey.tr();
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
                    resolvedTitle,
                    style: AppTextStyles.style16Medium.copyWith(
                      color: colors.tertiaryContainer,
                    ),
                  ),
                  Text(
                    resolvedActionLabel,
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.error,
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
                  color: colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, size: 16, color: colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
