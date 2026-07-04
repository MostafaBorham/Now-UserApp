import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class AppSelector extends StatefulWidget {
  const AppSelector({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onChanged,
    this.height = 36,
    this.labelColor,
    this.selectedColor,
    this.unselectedColor,
  });

  final List<String> items;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final double height;
  final Color? labelColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  State<AppSelector> createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  late int selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SelectorItem(
          label: widget.items[index],
          isSelected: index == selectedIndex,
          labelColor: widget.labelColor,
          selectedColor: widget.selectedColor,
          unselectedColor: widget.unselectedColor,
          onTap: () {
            setState(() => selectedIndex = index);
            widget.onChanged?.call(index);
          },
        ),
      ),
    );
  }
}

class SelectorItem extends StatelessWidget {
  const SelectorItem({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.labelColor,
    this.selectedColor,
    this.unselectedColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? labelColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: AppBorderRadius.brCircular30,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? colors.surfaceContainerHigh)
              : (unselectedColor ?? colors.onPrimaryContainer),
          borderRadius: AppBorderRadius.brCircular30,
        ),
        child: Text(
          label,
          style: AppTextStyles.style14Medium.copyWith(
            color: labelColor ?? colors.onTertiaryFixed,
          ),
        ),
      ),
    );
  }
}
