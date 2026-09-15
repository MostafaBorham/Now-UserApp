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
    this.isLoading = false,
  });

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.primary500Main, width: 1.5),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                child: FittedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary500Main,
                  ),
                ),
              )
            : AutoSizeText(
                title,
                textAlign: TextAlign.center,
                minFontSize: 10,
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.primary500Main,
                ),
              ),
      ),
    );
  }
}
