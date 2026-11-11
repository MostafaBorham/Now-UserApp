import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ProductFeaturesSizeOptionItem extends StatelessWidget {
  const ProductFeaturesSizeOptionItem({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary500Main : colors.white,
          borderRadius: AppBorderRadius.brCircular14,
          border: Border.all(
            color: isSelected ? colors.primary500Main : colors.neutral200,
          ),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
            label,
            style:
                (isSelected
                        ? AppTextStyles.style14SemiBold
                        : AppTextStyles.style14Medium)
                    .copyWith(
                      color: isSelected
                          ? colors.white
                          : colors.tertiaryContainer,
                    ),
          ),
        ),
      ),
    );
  }
}
