import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class PrimaryAppDisabledButton extends StatelessWidget {
  const PrimaryAppDisabledButton({
    super.key,
    required this.title,
    this.onTap,
    this.buttonPadding = 12,
  });

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(buttonPadding!),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent, width: 2),
        ),
        child: Center(
          child: AutoSizeText(
            title,
            textAlign: TextAlign.center,
            minFontSize: 10,
            style: AppTextStyles.style14Medium.copyWith(color: colors.onSurface),
          ),
        ),
      ),
    );
  }
}