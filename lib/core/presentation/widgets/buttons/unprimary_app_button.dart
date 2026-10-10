import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class UnPrimaryAppButton extends StatelessWidget {
  const UnPrimaryAppButton({
    super.key,
    required this.title,
    this.onTap,
    this.buttonPadding = 12,
    this.titleStyle,
    this.isLoading = false,
    this.side,
    this.titleColor,
    this.backgroundColor,
  });

  final String title;
  final VoidCallback? onTap;
  final double buttonPadding;

  /// Replaces the title with a circular indicator and disables taps.
  final bool isLoading;

  /// Overrides the default 14/Medium label style.
  final TextStyle? titleStyle;

  /// The outline; defaults to 1.5px in the primary color.
  final BorderSide? side;

  /// Colors the title and the loading indicator; defaults to primary.
  final Color? titleColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color foreground = titleColor ?? colors.primary500Main;
    final Color background = backgroundColor ?? Colors.transparent;
    final BorderSide outline =
        side ?? BorderSide(color: colors.primary500Main, width: 1.5);
    return OutlinedButton(
      onPressed: isLoading ? null : onTap,
      // A null onTap or a load only stops taps; the button keeps its colors.
      style: OutlinedButton.styleFrom(
        backgroundColor: background,
        disabledBackgroundColor: background,
        foregroundColor: foreground,
        disabledForegroundColor: foreground,
        side: outline,
        // Merged for the same reason as in PrimaryAppButton: the button's
        // Material would otherwise drop the theme's Cairo.
        textStyle: DefaultTextStyle.of(
          context,
        ).style.merge(titleStyle ?? AppTextStyles.style14Medium),
        // The old Container added the border to its padding; this keeps the
        // same size now that the outline is painted inside it.
        padding: EdgeInsets.all(buttonPadding + outline.width),
        minimumSize: const Size.fromHeight(0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hidden, not removed, so the button keeps its height while loading.
          Opacity(
            opacity: isLoading ? 0 : 1,
            child: FittedBox(fit: BoxFit.scaleDown, child: Text(title)),
          ),
          if (isLoading)
            SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            ),
        ],
      ),
    );
  }
}
