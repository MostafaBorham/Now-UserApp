import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// A soft grey card that lists the available payment methods with a single
/// (radio-style) selection, followed by an "Add New Card" outlined button.
///
/// Selection state is kept internally; [onChanged] reports the picked index
/// and [onAddNewCard] fires when the bottom button is tapped.
class PaymentMethodsCard extends StatefulWidget {
  const PaymentMethodsCard({
    super.key,
    this.initialIndex = 0,
    this.onChanged,
    this.onAddNewCard,
  });

  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final VoidCallback? onAddNewCard;

  @override
  State<PaymentMethodsCard> createState() =>
      _PaymentMethodsCardState();
}

class _PaymentMethodsCardState
    extends State<PaymentMethodsCard> {
  late int _selected = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Inline dummy data — no model classes (icon, circle tint, title, subtitle).
    final List<(IconData, Color, String, String?)> methods = [
      (
        Icons.credit_card,
        colors.secondaryContainer,
        'Payment Card',
        'Visa ****4587',
      ),
      (Icons.apple, colors.onSecondary, 'Apple Pay', null),
      (
        Icons.account_balance_wallet_outlined,
        colors.outlineVariant,
        'STC Pay',
        null,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            'Payment Method',
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          ...methods.indexed.map((entry) {
            final int index = entry.$1;
            final (IconData icon, Color tint, String title, String? subtitle) =
                entry.$2;
            final bool selected = index == _selected;
            return InkWell(
              onTap: () {
                setState(() => _selected = index);
                widget.onChanged?.call(index);
              },
              borderRadius: AppBorderRadius.brCircular12,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryFixed,
                  borderRadius: AppBorderRadius.brCircular12,
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: title == 'Apple Pay'
                            ? tint
                            : tint.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: title == 'Apple Pay' ? colors.onPrimary : tint,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 2,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.style16Medium.copyWith(
                              color: colors.tertiaryContainer,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: AppTextStyles.style14Regular.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? colors.primary
                              : colors.surfaceContainerLow,
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),
          InkWell(
            onTap: widget.onAddNewCard,
            borderRadius: AppBorderRadius.brCircular8,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              decoration: BoxDecoration(
                color: colors.onPrimary,
                borderRadius: AppBorderRadius.brCircular8,
                border: Border.all(color: colors.surfaceContainerLow),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Assets.media.images.svg.circleAddMoreBrokenIcon.svg(),
                  Text(
                    'Add New Card',
                    style: AppTextStyles.style16Medium.copyWith(
                      color: colors.onTertiaryFixed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
