import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular/views/top3_most_popular_view.dart';

class AllMostPopularFilterView extends StatelessWidget {
  const AllMostPopularFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => AspectRatio(
          aspectRatio: 0.75,
          child: Top3MostPopularView(categoryName: 'Devices')),
      separatorBuilder: (context, index) => 10.hSpace,
      itemCount: 4,
    );
  }
}
