import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
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
    this.isScrollable = false,
  });

  /// Optional error details shown under the title. Falls back to the generic
  /// "unable to reach servers" copy when null or empty.
  final String? message;

  /// Called when the user taps the retry button. The button is hidden when
  /// this is null.
  final VoidCallback? onRetry;

  /// When true, lays the widget out at a fixed natural size, centred inside a
  /// scroll view that fills at least the available height. Use inside a
  /// scrollable whose viewport changes (e.g. a `NestedScrollView` body / tab
  /// view) so the widget stays a constant size instead of scaling up and down
  /// with the scroll — mirrors [NoResultsWidget.isScrollable].
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // The whole column is laid out at its natural design size, then scaled down
    // as one unit to fit the space this widget is given (a tab view is far
    // shorter than a full screen). Everything — icon, texts, button — shrinks by
    // the same factor, so the proportions between them never change.
    final Widget content = Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Assets.media.images.svg.serverFailIcon.svg(width: 300),
              AutoSizeText(
                LangKeys.serverConnectionFailedKey.tr(),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.style24Bold.copyWith(
                  color: colors.black,
                ),
              ),
              AutoSizeText(
                (message == null || message!.isEmpty)
                    ? LangKeys.unableToReachServersKey.tr()
                    : message!.tr(),
                textAlign: TextAlign.center,
                maxLines: 4,
                style: AppTextStyles.style18Medium.copyWith(
                  color: colors.neutral500,
                ),
              ),
              if (onRetry != null) ...[
                15.hSpace,
                PrimaryAppPrefixIconButton(
                  title: LangKeys.retryKey.tr(),
                  onTap: onRetry,
                  prefixIcon: Assets.media.images.svg.retryIcon.svg(
                    colorFilter:
                        ColorFilter.mode(colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!isScrollable) return content;

    // Unbounded height in the scroll view lets the FittedBox settle at its
    // natural size (nothing to scale down against), so the widget no longer
    // grows and shrinks as the surrounding viewport changes while scrolling.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
          ),
        );
      },
    );
  }
}
