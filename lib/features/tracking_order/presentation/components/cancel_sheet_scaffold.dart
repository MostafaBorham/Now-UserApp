import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Keeps the header and actions visible while the body scrolls.
class CancelSheetScaffold extends StatelessWidget {
  const CancelSheetScaffold({
    super.key,
    required this.body,
    required this.footer,
    this.canClose = true,
    this.expand = false,
  });

  final Widget body;
  final Widget footer;
  final bool canClose;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LangKeys.cancelOrderKey.tr(),
                    style: AppTextStyles.style18Medium.copyWith(
                      color: context.colors.tertiaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: canClose
                      ? () => Navigator.of(context).pop()
                      : null,
                  color: context.colors.tertiaryContainer,
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),
          Flexible(
            fit: expand ? FlexFit.tight : FlexFit.loose,
            child: Align(
              heightFactor: 1,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: body,
              ),
            ),
          ),
          footer,
        ],
      ),
    );
  }
}
