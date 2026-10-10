import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class PrimaryAppButton extends StatelessWidget {
  const PrimaryAppButton({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
    this.titleStyle,
    this.prefixIcon,
    this.postfixIcon,
    this.buttonColor,
    this.buttonRadius = 8,
  });

  /// The one height every full-width button in the app shares.
  static const double height = 54;

  final String title;
  final VoidCallback? onTap;
  final double buttonRadius;

  /// Overrides the primary fill; a disabled button is grey regardless.
  final Color? buttonColor;

  /// Shown before / after the title, scaled down with it when space is short.
  final Widget? prefixIcon;
  final Widget? postfixIcon;

  /// Overrides the default 18/SemiBold label style.
  final TextStyle? titleStyle;

  /// Replaces the title with a circular indicator and disables taps.
  final bool isLoading;

  /// Greys out the button and disables taps while keeping the same size,
  /// so callers can toggle enabled/disabled without swapping widgets.
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // Loading disables taps but keeps the primary look, so the enabled and
    // disabled colors are the same and only isDisabled picks between them.
    final Color background = isDisabled
        ? colors.neutral500.withValues(alpha: 0.3)
        : buttonColor ?? colors.primary500Main;
    final Color foreground = isDisabled ? colors.neutral500 : colors.white;
    return ElevatedButton(
      onPressed: (isLoading || isDisabled) ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        disabledBackgroundColor: background,
        foregroundColor: foreground,
        disabledForegroundColor: foreground,
        shadowColor: Colors.transparent,
        // The button's own Material replaces the ambient text style rather
        // than merging into it, so merge here or the theme's Cairo is lost.
        textStyle: DefaultTextStyle.of(
          context,
        ).style.merge(titleStyle ?? AppTextStyles.style18SemiBold),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size.fromHeight(0),
        fixedSize: const Size.fromHeight(height),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.white,
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [?prefixIcon, Text(title), ?postfixIcon],
              ),
            ),
    );
  }
}
