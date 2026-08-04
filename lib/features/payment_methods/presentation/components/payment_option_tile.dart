import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

/// A single selectable payment row — a saved card or an alternative payment
/// method. Shows a leading brand badge, a title (+ optional subtitle) and a
/// trailing radio indicator. Tapping anywhere on the row selects it.
class PaymentOptionTile extends StatelessWidget {
  /// Pale-green fill of the selected row — no equivalent in the theme
  /// [ColorScheme].
  static const Color _selectedBackground = Color(0xFFF4FBF3);

  const PaymentOptionTile({
    super.key,
    required this.leading,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBackground : Colors.white,
          borderRadius: AppBorderRadius.brCircular16,
          border: isSelected
              ? Border.all(color: colors.primary, width: 1.25)
              : Border.all(color: colors.surfaceContainerLow, width: 1.25),
        ),
        child: Row(
          children: [
            SizedBox(width: 46, height: 46, child: leading),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.style16SemiBold.copyWith(
                      color: AppColors.optionTitle,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.style14Regular.copyWith(
                        color: AppColors.mutedLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _SelectionIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

/// Radio-style indicator: a green ring + filled dot when selected,
/// a plain grey ring when not.
class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColors.selectedIndicator
              : AppColors.unselectedIndicator,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.selectedIndicator,
                ),
              ),
            )
          : null,
    );
  }
}
