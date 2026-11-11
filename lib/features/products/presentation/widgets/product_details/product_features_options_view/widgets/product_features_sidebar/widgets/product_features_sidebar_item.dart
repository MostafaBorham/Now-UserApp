import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ProductFeaturesSidebarItem extends StatelessWidget {
  const ProductFeaturesSidebarItem({
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
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
          style:
              (isSelected
                      ? AppTextStyles.style14Bold
                      : AppTextStyles.style14Regular)
                  .copyWith(
                    fontSize: 13,
                    color: isSelected
                        ? colors.neutral1200
                        : colors.onPrimaryFixed,
                  ),
        ),
      ),
    );
  }
}
