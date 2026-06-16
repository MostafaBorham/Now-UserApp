import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/controllers/home/home_controller.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/app_borders.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeBannerSlider extends ConsumerWidget {
  HomeBannerSlider({super.key});

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
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 100.h,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                borderRadius: AppBorderRadius.brCircular16
              ),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 100.h,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.brCircular16,
                      color: colors.onPrimary,
                      border: AppBorders.b1(colors.inversePrimary)
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colors.primary,
                      ),
                    ),
                  ),
                  imageUrl: 'https://img.magnific.com/free-vector/stylish-big-sale-event-banner-buy-save-upto-50-percent_1017-59087.jpg?semt=ais_hybrid&w=740&q=80'),
            );
          },
          options: CarouselOptions(
            height: 150.h,
            viewportFraction: 0.9,
            enlargeCenterPage: false,
            autoPlay: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            onPageChanged: (index, _) {
              ref.read(_homeController.sliderIndexProvider.notifier).state = index;
            },
          ),
        ),
        AnimatedSmoothIndicator(
          activeIndex: ref.watch(_homeController.sliderIndexProvider),
          count: 4,
          effect: WormEffect(
            dotHeight: 10.h,
            dotWidth: 10.w,
            activeDotColor: colors.primary,
            dotColor: colors.onTertiary,
          ),
        )
      ],
    );
  }
}
