import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class PrimaryAppPrefixIconButton extends StatelessWidget {
  const PrimaryAppPrefixIconButton({super.key, required this.title, this.onTap, this.buttonPadding = 12, this.prefixIcon, this.buttonColor, this.buttonRadius, this.isLoading = false,});

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
  final double? buttonRadius;
  final Widget? prefixIcon;
  final Color? buttonColor;

  /// Replaces the content with a circular indicator and disables taps.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(buttonPadding!),
        decoration: BoxDecoration(
            color: buttonColor?? colors.primary,
            borderRadius: BorderRadius.circular(buttonRadius??8),
            border: Border.all(
                color:  Colors.transparent,
                width: 2
            )
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.onPrimary,
                  ),
                ),
              )
            : Row(
          spacing: 8,
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