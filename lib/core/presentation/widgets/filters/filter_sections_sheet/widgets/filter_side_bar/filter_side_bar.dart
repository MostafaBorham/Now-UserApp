import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_sections_sheet/widgets/filter_side_bar/widgets/filter_side_bar_item.dart';

class FilterSideBar extends StatelessWidget {
  const FilterSideBar({
    super.key,
    required this.titles,
    required this.selectedIndex,
    this.onSelected,
  });

  final List<String> titles;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return SizedBox(
      width: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            width: 1,
            child: ColoredBox(color: colors.dividerLight),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: List.generate(
              titles.length,
              (index) => FilterSideBarItem(
                title: titles[index],
                isSelected: index == selectedIndex,
                onTap: () => onSelected?.call(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
