import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/home_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AppSlider extends ConsumerWidget {
  AppSlider({super.key, this.activeDotColor, this.dotColor, required this.sliderItem, this.sliderSpace = 8, this.itemAspectRatio =1});
  final Color? activeDotColor;
  final Color? dotColor;
  final Widget sliderItem;
  final double? sliderSpace;
  final double? itemAspectRatio;
  final HomeController _homeController = HomeController();
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      spacing: 20,
      children: [
        CarouselSlider.builder(
          itemCount: 4,
          itemBuilder: (_, index, _) {
            return Padding(
              padding: EdgeInsets.all(sliderSpace!),
              child: sliderItem,
            );
          },
          options: CarouselOptions(
            // height: 150,
            enlargeCenterPage: false,
            autoPlay: true,
            aspectRatio: itemAspectRatio!,
            viewportFraction: 0.9,
            onPageChanged: (index, _) {
              ref.read(_homeController.sliderIndexProvider.notifier).state = index;
            },
          ),
        ),
        AnimatedSmoothIndicator(
          activeIndex: ref.watch(_homeController.sliderIndexProvider),
          count: 4,
          effect: WormEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: activeDotColor?? colors.primary,
            dotColor: dotColor?? colors.onTertiary,
          ),
        )
      ],
    );
  }
}
