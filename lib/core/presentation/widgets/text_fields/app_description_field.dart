import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/components/field_input_borders.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

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
    final InputBorder focused = filledDescriptionBorder.copyWith(
      borderSide: BorderSide(color: colors.primary500Main, width: 1.5),
    );
    return InputDirectionBuilder(
      controller: controller,
      builder: (BuildContext context, TextDirection? typedDirection) =>
          TextFormField(
            contextMenuBuilder: appContextMenuBuilder,
            controller: controller,
            maxLines: 4,
            maxLength: maxLength,
            textDirection: typedDirection,
            style: AppTextStyles.style14Regular.copyWith(color: colors.black),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: colors.onPrimaryContainer,
              hintText: hintTxt,
              hintStyle: AppTextStyles.style14Regular.copyWith(
                color: colors.onPrimaryFixed,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: filledDescriptionBorder,
              enabledBorder: filledDescriptionBorder,
              focusedBorder: focused,
              errorBorder: filledDescriptionBorder,
              focusedErrorBorder: focused,
            ),
          ),
    );
  }
}