import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class FilterSideBarItem extends StatelessWidget {
  const FilterSideBarItem({
    super.key,
    required this.title,
    required this.isSelected,
    this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(9, 14, 12, 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary500Main.withValues(alpha: 0.1)
              : null,
          border: BorderDirectional(
            start: BorderSide(
              color: isSelected ? colors.primary500Main : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          maxLines: 2,
          style: isSelected
              ? AppTextStyles.style13Bold.copyWith(color: colors.neutral1200)
              : AppTextStyles.style13Regular.copyWith(
                  color: colors.onPrimaryFixed,
                ),
        ),
      ),
    );
  }
}
