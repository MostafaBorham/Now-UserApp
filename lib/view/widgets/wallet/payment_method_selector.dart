import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';


class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({
    super.key,
    this.initialIndex = 0,
    this.onChanged,
  });

  final int initialIndex;


  final ValueChanged<int>? onChanged;

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  late int _selected = widget.initialIndex;

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    widget.onChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 4, bottom: 16),
          child: Text(
            LangKeys.paymentMethodKey.tr(),
            style: AppTextStyles.style14Medium.copyWith(
              color: colors.onSecondary,
            ),
          ),
        ),
        NowRadioTile(
          label: LangKeys.electronicPaymentKey.tr(),
          selected: _selected == 0,
          onTap: () => _select(0),
        ),
        const _OrDivider(),
        NowRadioTile(
          label: LangKeys.rewardPointsKey.tr(),
          selected: _selected == 1,
          onTap: () => _select(1),
          badge: 'Mustafa',
        ),
      ],
    );
  }
}

/// A single selectable radio row rendered as a soft rounded card.
///
/// Shows a [label] on the leading (right, in RTL) edge, an optional [badge]
/// pill, and a circular indicator that fills green with a check mark when
/// [selected]. Reusable on its own outside [PaymentMethodSelector].
class NowRadioTile extends StatelessWidget {
  const NowRadioTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Optional trailing pill text (e.g. an account name). Hidden when null.
  final String? badge;

  static const Color _green = Color(0xFF4BB749);
  static const Color _cardFill = Color(0xFFF6F6F6);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.1),
            borderRadius: AppBorderRadius.brCircular12,
          ),
          child: Row(
            spacing: 20,
            children: [
              _RadioIndicator(selected: selected),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ),
              if (badge != null) ...[_NameBadge(text: badge!)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular selection indicator: a thin grey ring when unselected, a filled
/// green circle with a white check mark when selected.
class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? NowRadioTile._green : Colors.transparent,
        border: Border.all(
          color: selected
              ? colors.primaryContainer.withValues(alpha: 0.5)
              : colors.onSurface,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}

/// Light-green rounded pill used for the trailing account name badge.
class _NameBadge extends StatelessWidget {
  const _NameBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.primary,
        ),
      ),
    );
  }
}

/// Centered "- أو -" (or) divider shown between the two options.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        LangKeys.orDividerKey.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}
