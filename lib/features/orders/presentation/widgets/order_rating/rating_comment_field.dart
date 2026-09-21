import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The compact, filled comment box the rating screen puts under every rateable
/// row. It grows from one line up to four as the shopper types and takes its
/// [fillColor] from the caller — white inside the products card, a neutral grey
/// for the courier and store sections.
class RatingCommentField extends StatelessWidget {
  const RatingCommentField({
    super.key,
    required this.hint,
    this.controller,
    this.fillColor,
    this.readOnly = false,
  });

  final String hint;
  final TextEditingController? controller;
  final Color? fillColor;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final InputBorder border = OutlineInputBorder(
      borderRadius: AppBorderRadius.brCircular6,
      borderSide: const BorderSide(color: Colors.transparent),
    );

    return TextField(
      controller: controller,
      readOnly: readOnly,
      minLines: 1,
      maxLines: 4,
      textInputAction: TextInputAction.newline,
      style: AppTextStyles.style14Regular.copyWith(color: colors.black),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: fillColor ?? colors.white,
        hintText: hint,
        hintStyle: AppTextStyles.style14Regular.copyWith(
          color: colors.neutral400,
        ),
        contentPadding: const EdgeInsets.all(12),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
