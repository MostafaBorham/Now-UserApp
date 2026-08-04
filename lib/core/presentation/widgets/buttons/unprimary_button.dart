import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class UnPrimaryButton extends StatelessWidget {
  const UnPrimaryButton({
    super.key,
    required this.title,
    this.onTap,
    this.buttonPadding = 12, this.borderColor, this.titleColor,
  });

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
  final Color? borderColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(buttonPadding!),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor?? colors.inversePrimary.withValues(alpha: 0.5), width: 1),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style14Medium.copyWith(color: titleColor?? colors.onSecondary),
          ),
        ),
      ),
    );
  }
}