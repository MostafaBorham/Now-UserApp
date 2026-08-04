import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// App-wide confirmation dialog: a title, a message and a Cancel / confirm pair.
///
/// The dialog is presentational only — it owns no state. The caller decides what
/// happens on confirm and drives [isLoading]; while it is true the confirm label
/// is replaced by a spinner, both buttons are disabled and the dialog can not be
/// dismissed (barrier + back button), so the action can never be fired twice.
///
/// Closing is the caller's job as well: pop the dialog once the action succeeds
/// and keep it open (with [isLoading] back to false) on failure.
///
/// Always open it through [show] so the barrier stays non-dismissible.
class AppCustomAlertDialog extends StatelessWidget {
  const AppCustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel,
    this.confirmColor,
    this.isLoading = false,
  });

  final String title;
  final String message;

  /// Label of the confirming action (e.g. Delete, Log Out).
  final String confirmLabel;

  /// Defaults to the localized "Cancel".
  final String? cancelLabel;

  /// Defaults to the destructive color (`colorScheme.onError`).
  final Color? confirmColor;

  final VoidCallback onConfirm;
  final bool isLoading;

  /// Shows [builder]'s dialog with a non-dismissible barrier.
  static Future<void> show(BuildContext context, WidgetBuilder builder) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color actionColor = confirmColor ?? colors.onError;

    // While the action is running the dialog must not be dismissible in any way.
    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // `AppTextStyles` sets `overflow: ellipsis` on every style, so
              // we override it here — the dialog wraps to as many lines as the
              // title/message need instead of truncating.
              Text(
                title,
                overflow: TextOverflow.visible,
                style: AppTextStyles.style16SemiBold.copyWith(
                  color: colors.tertiaryContainer,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                overflow: TextOverflow.visible,
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.neutral500,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 16),
              // Both buttons are `Flexible` so a long Cancel / confirm label
              // grows the button horizontally first, and once it hits the row's
              // share of the width the text wraps to a new line inside the
              // button instead of ellipsizing.
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Cancel is dimmed and disabled while the action is running.
                  Flexible(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        cancelLabel ?? LangKeys.cancelKey.tr(),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style14Medium.copyWith(
                          overflow: TextOverflow.visible,
                          color: colors.neutral500.withValues(
                            alpha: isLoading ? 0.4 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: isLoading ? null : onConfirm,
                    // Minimum width keeps the spinner and short labels
                    // aligned; longer labels grow the slot before wrapping.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 64),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: actionColor,
                                  ),
                                )
                              : Text(
                                  confirmLabel,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.style14Medium.copyWith(
                                    overflow: TextOverflow.visible,
                                    color: actionColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
