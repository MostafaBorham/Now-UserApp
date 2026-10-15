import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Full-width green call-to-action button (used for "Edit" and "Save").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// When true the label is replaced by a spinner and taps are ignored.
  final bool isLoading;

  /// Greys the button out and ignores taps, e.g. Save on a form nothing has
  /// changed in yet.
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDisabled
          ? context.colors.neutral500.withValues(alpha: 0.3)
          : context.colors.primary500Main,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading || isDisabled ? null : onPressed,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: context.colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? context.colors.neutral500
                          : context.colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
