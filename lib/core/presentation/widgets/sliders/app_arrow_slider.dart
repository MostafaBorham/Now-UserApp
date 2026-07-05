import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/features/home/presentation/controllers/home_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AppArrowSlider extends ConsumerWidget {
  AppArrowSlider({super.key, this.activeDotColor, this.dotColor, required this.sliderItem, this.sliderSpace = 8, this.itemAspectRatio =1});
  final Color? activeDotColor;
  final Color? dotColor;
  final Widget sliderItem;
  final double? sliderSpace;
  final double? itemAspectRatio;
  final HomeController _homeController = HomeController();
  final CarouselSliderController _controller = CarouselSliderController();
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Column(
      spacing: 20,
      children: [
        Row(
          spacing: 10,
          children: [
            InkWell(
              onTap: () {
                _controller.previousPage();
              },
              child: Material(
                shape: CircleBorder(),
                elevation: 4,
                shadowColor: colors.onSurface.withValues(alpha: 0.3),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.onPrimary,
                  child: Icon(Icons.arrow_back_ios,size: 20,color: colors.onSecondary,),
                ),
              ),
            ),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _controller,
                itemCount: 4,
                itemBuilder: (_, index, _) {
                  return sliderItem;
                },
                options: CarouselOptions(
                  // height: 150,
                  enlargeCenterPage: false,
                  viewportFraction: 1,
                  clipBehavior: Clip.none,
                  autoPlay: false,
                  aspectRatio: itemAspectRatio!,
                  onPageChanged: (index, _) {
                    ref.read(_homeController.sliderIndexProvider.notifier).state = index;
                  },
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _controller.nextPage();
              },
              child: Material(
                shape: CircleBorder(),
                elevation: 4,
                shadowColor: colors.onSurface.withValues(alpha: 0.3),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.onPrimary,
                  child: Icon(Icons.arrow_forward_ios,size: 20,color: colors.onSecondary,),
                ),
              ),
            )
          ],
        ),
     /*   CarouselSlider.builder(
          itemCount: 4,
          itemBuilder: (_, index, _) {
            return sliderItem;
          },
          options: CarouselOptions(
            // height: 150,
            enlargeCenterPage: false,
            autoPlay: false,
            aspectRatio: itemAspectRatio!,
            onPageChanged: (index, _) {
              ref.read(_homeController.sliderIndexProvider.notifier).state = index;
            },
          ),
        ),*/
        DotsIndicator(currentIndex: ref.watch(_homeController.sliderIndexProvider), itemCount: 4,activeColor: activeDotColor?? colors.primary,
          inactiveColor: dotColor?? colors.onTertiary,)
      ],
    );
  }
}


class DotsIndicator extends StatelessWidget {
  const DotsIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.grey,
    this.activeWidth = 20,
    this.inactiveWidth = 8,
    this.height = 8,
    this.spacing = 8,
    this.duration = const Duration(milliseconds: 250),
  });

  final int currentIndex;
  final int itemCount;

  final Color activeColor;
  final Color inactiveColor;

  final double activeWidth;
  final double inactiveWidth;
  final double height;
  final double spacing;

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
            (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeInOut,
            width: currentIndex == index
                ? activeWidth
                : inactiveWidth,
            height: height,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? activeColor
                  : inactiveColor,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}