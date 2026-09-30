import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The item-count badge on a cart icon: a white pill with the count in the
/// brand color, capped at `99+`.
class CartBadge extends StatelessWidget {
  const CartBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.primary500Main, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.style12Medium.copyWith(
          color: colors.primary500Main,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
