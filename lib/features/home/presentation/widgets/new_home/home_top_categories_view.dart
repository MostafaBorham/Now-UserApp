import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/top_categories_controller.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_category_item.dart';

class HomeTopCategoriesView extends ConsumerWidget {
  const HomeTopCategoriesView({super.key});
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return CarouselSlider.builder(
      itemCount: ref.read(topCategoriesCountProvider),
      itemBuilder: (_, index, _) => const HomeTopCategoryItem(),
      options: CarouselOptions(
        onPageChanged: (index, reason) {
          debugPrint('changed$index');
          return ref.read(currentTopCategoryIndexProvider.notifier).state = index;
        },
        enlargeCenterPage: false,
        autoPlay: true,
        aspectRatio: 0.75,
        viewportFraction: 1,
      ),
    );
  }
}
