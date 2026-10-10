import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';

class PrimaryGradientAppButton extends StatelessWidget {
  const PrimaryGradientAppButton({
    super.key,
    required this.title,
    this.onTap,
    required this.buttonGradient,
  });

  final String title;
  final GestureTapCallback? onTap;
  final Gradient buttonGradient;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: PrimaryAppButton.height,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent, width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style24SemiBold.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
