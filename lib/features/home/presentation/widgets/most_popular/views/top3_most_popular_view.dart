import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/cards/most_popular_top1_item_card.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/cards/most_popular_top2_item_card.dart';

import '../cards/most_popular_top3_item_card.dart';

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
            child: MostPopularTop1ItemCard()),
        Expanded(
          flex: 3,
          child: Row(
            spacing: 20,
            children: [
              Expanded(child: MostPopularTop2ItemCard()),
              Expanded(child: MostPopularTop3ItemCard()),
            ],
          ),
        ),
      ],
    );
  }
}
