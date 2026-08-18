import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// App-wide "copy code to clipboard" action.
///
/// Copies [code] to the system clipboard and confirms it with a single,
/// consistent floating snackbar, so every place that lets the user copy a code
/// behaves and looks the same.
class CopyToClipboard {
  const CopyToClipboard._();

  /// Copies [code] to the clipboard and shows the confirmation snackbar on the
  /// nearest [ScaffoldMessenger], replacing any snackbar currently on screen.
  static void copy(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));

    final AppColorScheme colors = context.colors;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            LangKeys.codeCopiedKey.tr(namedArgs: <String, String>{'code': code}),
            style: AppTextStyles.style16SemiBold.copyWith(color: colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          duration: const Duration(seconds: 2),
          padding: const EdgeInsets.all(16),
          backgroundColor: colors.primary500Main,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      );
  }
}
