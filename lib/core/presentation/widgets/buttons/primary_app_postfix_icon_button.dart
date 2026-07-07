import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class PrimaryAppPostfixIconButton extends StatelessWidget {
  const PrimaryAppPostfixIconButton({super.key, required this.title, this.onTap, this.buttonPadding = 12, this.postfixIcon,});

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
  final Widget? postfixIcon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(buttonPadding!),
        decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color:  Colors.transparent,
                width: 2
            )
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.onPrimary,
                ),
              ),
              postfixIcon??SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}