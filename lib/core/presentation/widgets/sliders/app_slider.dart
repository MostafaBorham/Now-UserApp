import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return sliderItems.isEmpty? LayoutBuilder(
      builder: (context,con) {
        return Container(
          width: con.maxWidth,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          height: con.maxWidth*0.5,
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16)
          ),
          child: Assets.media.images.png.noImageAvail.image(

          ),
        );
      }
    ) : Column(
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
          count: sliderItems.length,
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
