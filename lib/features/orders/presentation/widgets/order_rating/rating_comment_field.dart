import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

/// The compact, filled comment box the rating screen puts under every rateable
/// row. It grows from one line up to four as the shopper types and takes its
/// [fillColor] from the caller — white inside the products card, a neutral grey
/// for the courier and store sections. An editable box takes at most
/// [maxLength] characters and counts them underneath; a read-only one shows a
/// submitted comment as it is.
class RatingCommentField extends StatelessWidget {
  /// The product's limit; the backend itself accepts up to 1000.
  static const int maxLength = 400;

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

    return InputDirectionBuilder(
      controller: controller,
      builder: (BuildContext context, TextDirection? typedDirection) =>
          TextField(
            contextMenuBuilder: appContextMenuBuilder,
            controller: controller,
            readOnly: readOnly,
            maxLength: readOnly ? null : maxLength,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            textDirection: typedDirection,
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
              focusedBorder: readOnly
                  ? border
                  : border.copyWith(
                      borderSide: BorderSide(
                        color: colors.primary500Main,
                        width: 1.5,
                      ),
                    ),
            ),
          ),
    );
  }
}
