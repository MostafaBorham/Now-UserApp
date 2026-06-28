import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/filters_items/most_popular_horizontal_item.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/filters_items/most_popular_vertical_item.dart';

class Top3MostPopularView extends StatelessWidget {
  const Top3MostPopularView({super.key, required this.categoryName});
  final String categoryName;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          categoryName,
          style: TextStyle(
            color: colors.onSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Expanded(
          flex: 2,
            child: MostPopularHorizontalItem()),
        /*        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: colors.primary,
                ),
              ),
              Expanded(
                child: Container(
                  color: colors.error,
                ),
              )
            ],
          ),
        )*/
        Expanded(
          flex: 3,
          child: Row(
            spacing: 20,
            children: [
              Expanded(child: MostPopularVerticalItem()),
              Expanded(child: MostPopularVerticalItem()),
            ],
          ),
        ),
      ],
    );
  }
}
