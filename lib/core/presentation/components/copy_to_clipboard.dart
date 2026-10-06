import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';

/// App-wide "copy code to clipboard" action.
///
/// Copies [code] to the system clipboard and confirms it with the app's
/// standard success toast, so every place that lets the user copy a code
/// behaves and looks the same.
class CopyToClipboard {
  const CopyToClipboard._();

  static void copy(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppToast.showSuccess(
      context,
      LangKeys.codeCopiedKey.tr(namedArgs: <String, String>{'code': code}),
    );
  }
}
