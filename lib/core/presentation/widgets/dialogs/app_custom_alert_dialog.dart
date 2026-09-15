import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';












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


  final String confirmLabel;


  final String? cancelLabel;


  final Color? confirmColor;

  final VoidCallback onConfirm;
  final bool isLoading;


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




              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

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
