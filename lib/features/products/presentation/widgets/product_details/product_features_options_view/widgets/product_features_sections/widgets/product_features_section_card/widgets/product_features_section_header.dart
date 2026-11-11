import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ProductFeaturesSectionHeader extends StatelessWidget {
  const ProductFeaturesSectionHeader({
    super.key,
    required this.title,
    required this.isCollapsed,
    this.onTap,
  });

  final String title;
  final bool isCollapsed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.style14Bold.copyWith(
              color: colors.neutral1100,
            ),
          ),
          Icon(
            isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
            size: 12,
            color: colors.neutral1100,
          ),
        ],
      ),
    );
  }
}
