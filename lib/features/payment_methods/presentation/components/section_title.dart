import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

/// Section header reused across the Payment Methods screen
/// ("Saved Cards", "Another Payment Method", "Add New Card").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.style16SemiBold.copyWith(
        color: AppColors.sectionTitle,
      ),
    );
  }
}
