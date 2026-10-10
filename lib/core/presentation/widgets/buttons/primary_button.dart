import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';


class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    this.onTap,
    this.titleColor, this.buttonColor,
    this.isLoading = false,
  });

  final String title;
  final GestureTapCallback? onTap;
  final Color? titleColor;
  final Color? buttonColor;


  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color foreground = titleColor ?? colors.white;
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: PrimaryAppButton.height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: buttonColor?? colors.black.withValues(alpha: 0.9),
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
                    color: foreground,
                  ),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style14Medium.copyWith(color: foreground),
                ),
              ),
      ),
    );
  }
}
