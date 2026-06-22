import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/components/field_input_borders.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class AppDescriptionField extends StatelessWidget {
  const AppDescriptionField({super.key, required this.hintTxt});
  final String hintTxt;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return TextFormField(
      maxLines: 5,
      style: AppTextStyles.style14Regular.copyWith(color: colors.onSecondary),
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.onPrimaryContainer,
        hintText: hintTxt,
        hintStyle: AppTextStyles.style14Regular.copyWith(
          color: colors.onPrimaryFixed
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: filledDescriptionBorder,
        enabledBorder: filledDescriptionBorder,
        focusedBorder: filledDescriptionBorder,
        errorBorder: filledDescriptionBorder,
        focusedErrorBorder: filledDescriptionBorder,
      ),
    );
  }
}