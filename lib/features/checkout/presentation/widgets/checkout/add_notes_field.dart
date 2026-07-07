import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AddNotesField extends StatelessWidget {
  const AddNotesField({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return TextFormField(
      minLines: 3,
      style: AppTextStyles.style16Medium.copyWith(
          color: colors.onSecondary
      ),
      maxLines: 8,
      decoration: InputDecoration(
        hintText: 'Add notes.....',
        hintStyle: AppTextStyles.style16Medium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.7)
        ),
        filled: true,
        fillColor: colors.onSurface.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
