import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/components/field_input_borders.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AppDescriptionField extends StatelessWidget {
  const AppDescriptionField({
    super.key,
    required this.hintTxt,
    this.controller,
    this.maxLength,
  });
  final String hintTxt;
  final TextEditingController? controller;

  /// Stops typing at this many characters, without showing a counter.
  final int? maxLength;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return TextFormField(
      controller: controller,
      maxLines: 4,
      maxLength: maxLength,
      style: AppTextStyles.style14Regular.copyWith(color: colors.black),
      decoration: InputDecoration(
        counterText: '',
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