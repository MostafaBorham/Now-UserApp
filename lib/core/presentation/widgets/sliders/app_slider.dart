import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/home_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AppSlider extends ConsumerWidget {
  AppSlider({super.key, this.activeDotColor, this.dotColor, required this.sliderItems, this.sliderSpace = 8, this.itemAspectRatio =1,});
  final Color? activeDotColor;
  final Color? dotColor;
  final List<Widget> sliderItems;
  final double? sliderSpace;
  final double? itemAspectRatio;
  final HomeController _homeController = HomeController();
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final bool isSingleItem = sliderItems.length == 1;
    return sliderItems.isEmpty? const SizedBox.shrink() : Column(
      spacing: 20,
      children: [
        CarouselSlider.builder(
          itemCount: sliderItems.length,
          itemBuilder: (_, index, _) {
            return Padding(
              padding: EdgeInsets.all(sliderSpace!),
              child: sliderItems.elementAt(index),
            );
          },
          options: CarouselOptions(
            // height: 150,
            enlargeCenterPage: false,
            autoPlay: !isSingleItem,
            scrollPhysics: isSingleItem ? const NeverScrollableScrollPhysics() : null,
            aspectRatio: itemAspectRatio!,
            viewportFraction: isSingleItem ? 1 : 0.9,
            onPageChanged: isSingleItem
                ? null
                : (index, _) {
                    ref.read(_homeController.sliderIndexProvider.notifier).state = index;
                  },
          ),
        ),
        if (!isSingleItem)
          AnimatedSmoothIndicator(
            activeIndex: ref.watch(_homeController.sliderIndexProvider),
            count: sliderItems.length,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: activeDotColor?? colors.primary500Main,
              dotColor: dotColor?? colors.onTertiary,
            ),
          ),
      ],
    );
  }
}
