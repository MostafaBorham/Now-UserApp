import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Full-width green call-to-action button (used for "Edit" and "Save").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// When true the label is replaced by a spinner and taps are ignored.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGreen,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.buttonForeground,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.buttonForeground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
