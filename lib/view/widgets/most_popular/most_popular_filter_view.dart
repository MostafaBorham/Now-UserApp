import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/filters_items/most_popular_horizontal_item.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/top3_most_popular_view.dart';

class MostPopularFilterView extends StatelessWidget {
  const MostPopularFilterView({super.key, required this.filterName});

  final String filterName;
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Top3MostPopularView(categoryName: filterName),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        SliverList.separated(
          itemCount: 4,
          itemBuilder: (context, index) => const MostPopularHorizontalItem(),
          separatorBuilder: (context, index) => 10.hSpace,
        ),
      ],
    );
  }
}