import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class UnPrimaryGradientAppButton extends StatelessWidget {
  const UnPrimaryGradientAppButton({
    super.key,
    required this.title,
    this.onTap,
    this.buttonPadding = 12, required this.buttonGradient, this.backgroundColor,
  });

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
  final Gradient buttonGradient;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(buttonPadding!),
          decoration: BoxDecoration(
            color: backgroundColor?? colors.onPrimary,
            // borderRadius: BorderRadius.circular(8),
            // border: Border.all(color: colors.primary, width: 2),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style16Medium.copyWith(
              foreground: Paint()
                ..shader = buttonGradient.createShader(
                  const Rect.fromLTWH(0, 0, 300, 70),
                ),
            ),
          ),
        ),
      ),
    );
  }
}
