import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.focusNode,
    this.maxLength,
    this.inputFormatters,
  });
  final String hintTxt;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Stops typing at this many characters and counts them underneath.
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
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
            focusNode: focusNode,
            maxLines: 4,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            textDirection: typedDirection,
            style: AppTextStyles.style14Regular.copyWith(color: colors.black),
            decoration: InputDecoration(
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
