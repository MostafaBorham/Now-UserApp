import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class PrimaryAppDisabledButton extends StatelessWidget {
  const PrimaryAppDisabledButton({
    super.key,
    required this.title,
    this.buttonPadding = 12,
  });

  final String title;
  final double? buttonPadding;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(buttonPadding!),
      decoration: BoxDecoration(
        color: colors.neutral500.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent, width: 2),
      ),
      child: Center(
        child: AutoSizeText(
          title,
          textAlign: TextAlign.center,
          minFontSize: 10,
          style: AppTextStyles.style14Medium.copyWith(color: colors.neutral500),
        ),
      ),
    );
  }
}