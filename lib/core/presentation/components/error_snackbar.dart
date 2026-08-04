import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// App-wide error snackbar.
///
/// A single floating, pill-shaped snackbar used everywhere the app needs to
/// surface an error message, so the look stays consistent across features.
///
/// [message] may be a [LangKeys] key or a raw server message — it is passed
/// through `.tr()`, which leaves non-key strings untouched.
class ErrorSnackBar {
  const ErrorSnackBar._();

  /// Shows the error snackbar on the nearest [ScaffoldMessenger], replacing any
  /// snackbar currently on screen.
  static void show(BuildContext context, String message) {
    final AppColorScheme colors = context.colors;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_build(colors, message));
  }

  /// Builds the styled [SnackBar]. Exposed for callers that need the raw
  /// snackbar (e.g. their own [ScaffoldMessenger] handling); most callers should
  /// use [show].
  static SnackBar _build(AppColorScheme colors, String message) {
    return SnackBar(
      content: Text(
        message.tr(),
        style: AppTextStyles.style16SemiBold.copyWith(color: colors.white),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      padding: const EdgeInsets.all(16),
      backgroundColor: colors.onError,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}