import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class PrimaryAppPrefixIconButton extends StatelessWidget {
  const PrimaryAppPrefixIconButton({super.key, required this.title, this.onTap, this.buttonPadding = 12, this.prefixIcon,});

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
  final Widget? prefixIcon;

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
        child: Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            prefixIcon??SizedBox.shrink(),
            AutoSizeText(
              title,
              textAlign: TextAlign.center,
              minFontSize: 10,
              style: AppTextStyles.style14Medium.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}