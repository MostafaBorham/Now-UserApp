import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';

class ServerConnectionErrorWidget extends StatelessWidget {
  const ServerConnectionErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  /// Optional error details shown under the title. Falls back to the generic
  /// "unable to reach servers" copy when null or empty.
  final String? message;

  /// Called when the user taps the retry button. The button is hidden when
  /// this is null.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Assets.media.images.svg.serverFailIcon.svg(width: 300),
          AutoSizeText(
            LangKeys.serverConnectionFailedKey.tr(),
            style: AppTextStyles.style24Bold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          AutoSizeText(
            (message == null || message!.isEmpty)
                ? LangKeys.unableToReachServersKey.tr()
                : message!.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style16Regular,
          ),
          if (onRetry != null) ...[
            15.hSpace,
            PrimaryAppPrefixIconButton(
              title: LangKeys.retryKey.tr(),
              onTap: onRetry,
              prefixIcon: Assets.media.images.svg.retryIcon.svg(
                colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
