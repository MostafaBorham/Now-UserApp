import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';

class AppRateSelector extends StatefulWidget {
  const AppRateSelector({
    super.key,
    required this.ratings,
    this.initialIndex,
    this.onChanged,
    this.starSize = 15,
    this.labelColor,
    this.starColor,
    this.selectedColor,
    this.unselectedColor,
  });

  final List<String> ratings;
  final int? initialIndex;
  final ValueChanged<int>? onChanged;
  final double starSize;
  final Color? labelColor;
  final Color? starColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  State<AppRateSelector> createState() => _AppRateSelectorState();
}

class _AppRateSelectorState extends State<AppRateSelector> {
  late int? selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: List.generate(widget.ratings.length, (index) {
        return RateSelectorItem(
          rateRatio: widget.ratings[index],
          isSelected: index == selectedIndex,
          starSize: widget.starSize,
          labelColor: widget.labelColor,
          starColor: widget.starColor,
          selectedColor: widget.selectedColor,
          unselectedColor: widget.unselectedColor,
          onTap: () {
            setState(() => selectedIndex = index);
            widget.onChanged?.call(index);
          },
        );
      }),
    );
  }
}

class RateSelectorItem extends StatelessWidget {
  const RateSelectorItem({
    super.key,
    required this.rateRatio,
    required this.isSelected,
    this.starSize = 15,
    this.onTap,
    this.labelColor,
    this.starColor,
    this.selectedColor,
    this.unselectedColor,
  });

  final String rateRatio;
  final bool isSelected;
  final double starSize;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? starColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: AppBorderRadius.brCircular30,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? colors.tertiaryFixed)
              : (unselectedColor ?? colors.onPrimaryContainer),
          borderRadius: AppBorderRadius.brCircular30,
        ),
        child: AppRateWidget(
          starColor: starColor ?? colors.surface,
          rateRatio: rateRatio,
          size: starSize,
          rateColor: labelColor ?? colors.onSecondary,
        ),
      ),
    );
  }
}
