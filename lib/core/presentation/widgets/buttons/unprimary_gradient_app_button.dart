import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class UnPrimaryGradientAppButton extends StatelessWidget {
  const UnPrimaryGradientAppButton({
    super.key,
    required this.title,
    this.onTap,
    this.buttonPadding = 12,
    required this.buttonGradient,
    this.backgroundColor,
    this.isLoading = false,
  });

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;
  final Gradient buttonGradient;
  final Color? backgroundColor;


  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(2),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(buttonPadding!),
          decoration: BoxDecoration(
            color: backgroundColor ?? colors.white,
            borderRadius: BorderRadius.circular(8),

          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.primary500Main,
                    ),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
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
      ),
    );
  }
}
