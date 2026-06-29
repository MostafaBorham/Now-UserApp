import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/widgets/home/most_popular_item.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/cards/most_popular_item_card.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/cards/most_popular_top1_item_card.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/views/top3_most_popular_view.dart';

class MostPopularFilterView extends StatelessWidget {
  const MostPopularFilterView({super.key, required this.filterName});

  final String filterName;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AspectRatio(
              aspectRatio: 0.75,
              child: Top3MostPopularView(categoryName: filterName)),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        SliverList.separated(
          itemCount: 4,
          itemBuilder: (context, index) => AspectRatio(
              aspectRatio: 2.1,
              child: const MostPopularItemCard()),
          separatorBuilder: (context, index) => 10.hSpace,
        ),
      ],
    );
  }
}