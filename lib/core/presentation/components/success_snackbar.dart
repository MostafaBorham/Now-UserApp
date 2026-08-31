import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// App-wide success snackbar.
///
/// A single floating, pill-shaped snackbar used everywhere the app needs to
/// confirm a successful action, so the look stays consistent across features.
/// Mirrors [ErrorSnackBar], differing only in its (brand green) background.
///
/// [message] may be a [LangKeys] key or a raw message — it is passed through
/// `.tr()`, which leaves non-key strings untouched.
class SuccessSnackBar {
  const SuccessSnackBar._();

  /// Shows the success snackbar on the nearest [ScaffoldMessenger], replacing
  /// any snackbar currently on screen.
  static void show(BuildContext context, String message) {
    final AppColorScheme colors = context.colors;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_build(colors, message));
  }

  static SnackBar _build(AppColorScheme colors, String message) {
    return SnackBar(
      content: Text(
        message.tr(),
        style: AppTextStyles.style16SemiBold.copyWith(color: colors.white),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      padding: const EdgeInsets.all(16),
      backgroundColor: colors.primary500Main,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
