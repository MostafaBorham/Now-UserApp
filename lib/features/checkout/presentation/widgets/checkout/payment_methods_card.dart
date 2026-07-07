import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/payment_methods_radio_group.dart';

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

    // Inline dummy data — no model classes.
    final List<PaymentMethodEntry> methods = [
      (
        icon: Icons.credit_card,
        color: colors.secondaryContainer,
        solid: false,
        title: 'Payment Card',
        subtitle: 'Visa ****4587',
      ),
      (
        icon: Icons.apple,
        color: colors.onSecondary,
        solid: true,
        title: 'Apple Pay',
        subtitle: null,
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        color: colors.outlineVariant,
        solid: false,
        title: 'STC Pay',
        subtitle: null,
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
          PaymentMethodsRadioGroup(
            methods: methods,
            selectedIndex: _selected,
            onChanged: (index) {
              setState(() => _selected = index);
              widget.onChanged?.call(index);
            },
          ),
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
