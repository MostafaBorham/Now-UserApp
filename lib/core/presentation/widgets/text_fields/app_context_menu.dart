import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The long-press menu (Cut / Copy / Paste / Select all) for every text field.
///
/// Material's toolbar paints itself with `surface`, which here is the brand
/// yellow, and its labels with `onSurface`, a pale grey, so the menu was hard
/// to read. It gets its own white scheme instead; the overflow "⋮" icon reads
/// `onSurfaceVariant`. iOS draws Apple's own toolbar and ignores these.
Widget appContextMenuBuilder(
  BuildContext context,
  EditableTextState editableTextState,
) {
  final theme = Theme.of(context);
  final colors = context.colors;
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: colors.white,
        onSurface: colors.black,
        onSurfaceVariant: colors.black,
      ),
    ),
    child: AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    ),
  );
}
