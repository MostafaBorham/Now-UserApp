import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';


class PrimaryAppButton extends StatelessWidget {
  const PrimaryAppButton({
    super.key,
    required this.title,
    this.onTap,
    this.buttonPadding = 12,
    this.isLoading = false,
    this.isDisabled = false,
    this.titleStyle,
  });

  final String title;
  final GestureTapCallback? onTap;
  final double? buttonPadding;


  final TextStyle? titleStyle;


  final bool isLoading;



  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: (isLoading || isDisabled) ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(buttonPadding!),
        decoration: BoxDecoration(
          color: isDisabled
              ? colors.neutral500.withValues(alpha: 0.3)
              : colors.primary500Main,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent, width: 2),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.white,
                  ),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: (titleStyle ?? AppTextStyles.style18SemiBold).copyWith(
                    color: isDisabled ? colors.neutral500 : colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
