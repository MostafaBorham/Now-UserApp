import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// A single "label … value" line used inside the Delivery Details card and the
/// amount card. Pass either a plain [value] string or a custom [trailing]
/// widget (e.g. a price with its currency glyph); the trailing content is
/// always pinned to the end of the row.
class LabeledDetailRow extends StatelessWidget {
  const LabeledDetailRow({
    super.key,
    required this.label,
    this.value,
    this.trailing,
    this.valueColor,
  }) : assert(
         value != null || trailing != null,
         'Provide either a value or a trailing widget.',
       );

  final String label;
  final String? value;
  final Widget? trailing;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.style14Regular.copyWith(color: colors.onSurface),
        ),
        12.wSpace,
        Expanded(
          child: trailing != null
              ? Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing,
                )
              : Text(
                  value!,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style14Medium.copyWith(
                    color: valueColor ?? colors.onSecondary,
                  ),
                ),
        ),
      ],
    );
  }
}
