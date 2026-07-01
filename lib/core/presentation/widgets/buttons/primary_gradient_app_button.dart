import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';


class PrimaryGradientAppButton extends StatelessWidget {
  const PrimaryGradientAppButton({
    super.key,
    required this.title,
    this.onTap,
    this.buttonPadding = 12, required this.buttonGradient,
  });

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
  final Gradient buttonGradient;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(buttonPadding!),
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent, width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style14Medium.copyWith(color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}