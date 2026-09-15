import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';




class VerificationHeadline extends StatelessWidget {
  const VerificationHeadline({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.style24SemiBold.copyWith(
            color: context.colors.tertiaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        DefaultTextStyle.merge(
          maxLines: 2,
          style: AppTextStyles.style14Regular.copyWith(
            color: context.colors.neutral500,
          ),
          child: subtitle,
        ),
      ],
    );
  }
}
