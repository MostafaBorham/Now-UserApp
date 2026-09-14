import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// A value selector shaped like [AppTabBar]: a rounded grey track with a
/// highlighted pill marking the selected segment. Unlike a tab bar it has no
/// paged views — it only reports the selected index through [onChanged].
///
/// Segments share the available width equally.
class AppSegmentedSelector extends StatefulWidget {
  const AppSegmentedSelector({
    super.key,
    required this.items,
    required this.selectedColor,
    this.initialIndex = 0,
    this.onChanged,
    this.height = 58,
    this.trackColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.itemIcons,
  }) : assert(
         itemIcons == null || itemIcons.length == items.length,
         'itemIcons must be null or the same length as items',
       );

  final List<String> items;

  /// Fill color of the pill behind the selected segment.
  final Color selectedColor;

  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final double height;

  /// Background of the rounded track behind all segments. Defaults to the
  /// theme's light grey (`context.colors.onPrimaryContainer`), the same fill
  /// the app's other grey pills use.
  final Color? trackColor;

  final Color? selectedLabelColor;

  /// Label color of the unselected segments. Defaults to
  /// `context.colors.tertiaryContainer`, the same near-black the app's input
  /// text uses.
  final Color? unselectedLabelColor;

  /// Optional prefix icon per segment. Pass `null` at an index to omit that
  /// segment's icon while keeping icons on others. Must match [items.length]
  /// when provided.
  final List<Widget?>? itemIcons;

  @override
  State<AppSegmentedSelector> createState() => _AppSegmentedSelectorState();
}

class _AppSegmentedSelectorState extends State<AppSegmentedSelector> {
  late int selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.trackColor ?? colors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(29),
      ),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          return Expanded(
            child: _SegmentItem(
              label: widget.items[index],
              icon: widget.itemIcons?[index],
              isSelected: index == selectedIndex,
              selectedColor: widget.selectedColor,
              selectedLabelColor: widget.selectedLabelColor,
              unselectedLabelColor: widget.unselectedLabelColor,
              onTap: () {
                if (index == selectedIndex) return;
                setState(() => selectedIndex = index);
                widget.onChanged?.call(index);
              },
            ),
          );
        }),
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedLabelColor,
    this.icon,
    this.selectedLabelColor,
    this.onTap,
  });

  final String label;
  final Widget? icon;
  final bool isSelected;
  final Color selectedColor;
  final Color? selectedLabelColor;
  final Color? unselectedLabelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color labelColor = isSelected
        ? (selectedLabelColor ?? colors.white)
        : (unselectedLabelColor ?? colors.tertiaryContainer);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            if (icon != null)
              ColorFiltered(
                colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                child: icon!,
              ),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: AppTextStyles.style14SemiBold.copyWith(color: labelColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
