import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';






class PrivacySection extends StatelessWidget {
  const PrivacySection({
    super.key,
    required this.title,
    required this.body,
    this.titleStyle,
  });

  final String title;
  final String body;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: (titleStyle ?? AppTextStyles.style16Medium).copyWith(
            color: colors.tertiaryContainer,
            overflow: TextOverflow.visible,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          body,
          style: AppTextStyles.style14Regular.copyWith(
            color: colors.outline,
            height: 1.5,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
