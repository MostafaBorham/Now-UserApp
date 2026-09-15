import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class CopyToClipboard {
  const CopyToClipboard._();

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
