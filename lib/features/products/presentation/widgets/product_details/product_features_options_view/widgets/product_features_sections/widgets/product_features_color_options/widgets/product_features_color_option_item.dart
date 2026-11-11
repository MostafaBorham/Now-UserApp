import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ProductFeaturesColorOptionItem extends StatelessWidget {
  const ProductFeaturesColorOptionItem({
    super.key,
    required this.name,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colors.primary500Main
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: colors.white) : null,
                  ),
                ),
              ),
              if (isSelected)
                PositionedDirectional(
                  top: 3,
                  start: 1,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.primary500Main,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.white),
                    ),
                    child: Icon(Icons.check, size: 12, color: colors.white),
                  ),
                ),
            ],
          ),
          Text(
            name,
            style:
                (isSelected
                        ? AppTextStyles.style12SemiBold
                        : AppTextStyles.style12Regular)
                    .copyWith(
                      fontSize: 11,
                      height: 1.5,
                      color: isSelected
                          ? colors.neutral1100
                          : colors.neutral500,
                    ),
          ),
        ],
      ),
    );
  }
}
