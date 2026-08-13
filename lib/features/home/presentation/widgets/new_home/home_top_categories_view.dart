import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_category_item.dart';

class HomeTopCategoriesView extends StatelessWidget {
  const HomeTopCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: 3,
      itemBuilder: (_, index, _) {
          return HomeTopCategoryItem();
        return Container(
          color: index==0? Colors.red : Colors.blue,
        );
      },
      options: CarouselOptions(
        enlargeCenterPage: false,
        autoPlay: true,
        aspectRatio: 0.8,
        viewportFraction: 1,
      ),
    );
  }
}
