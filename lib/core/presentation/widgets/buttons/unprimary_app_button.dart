import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class UnPrimaryAppButton extends StatelessWidget {
  const UnPrimaryAppButton({
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
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(buttonPadding!),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.primary, width: 1.5),
        ),
        child: AutoSizeText(
          title,
          textAlign: TextAlign.center,
          minFontSize: 10,
          style: AppTextStyles.style14Medium.copyWith(color: colors.primary),
        ),
      ),
    );
  }
}
