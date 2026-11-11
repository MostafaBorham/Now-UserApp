import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class FilterSelectableChip extends StatelessWidget {
  const FilterSelectableChip({
    super.key,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBorderColor,
    required this.borderRadius,
    required this.padding,
    required this.child,
    this.selectedBorderWidth = 1,
    this.onTap,
  });

  final bool isSelected;
  final Color selectedColor;
  final Color selectedBorderColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final double selectedBorderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Ink(
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: isSelected ? selectedBorderColor : colors.neutral200,
            width: isSelected ? selectedBorderWidth : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
