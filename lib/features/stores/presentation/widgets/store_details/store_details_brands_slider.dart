import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_arrow_slider.dart';

class StoreDetailsBrandsSlider extends StatelessWidget {
  const StoreDetailsBrandsSlider({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        // The wordmark is painted with the design's diagonal white-to-brand
        // gradient, so it fades into the page on the left. Left-to-right in
        // both locales — the word itself is always latin.
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.08, 0.63],
            colors: [
              colors.onPrimary.withValues(alpha: 0.8),
              colors.secondaryFixedDim,
            ],
          ).createShader(bounds),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'GALAXY',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 96,
                letterSpacing: -4,
                height: 1,
                color: colors.secondaryFixedDim,
              ),
            ),
          ),
        ),
        AppArrowSlider(
          sliderItem: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.circular(
                20,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.secondaryFixedDim
                      .withValues(alpha: 0.4),
                  offset: Offset(0, 20),
                  blurRadius: 100,
                ),
              ],
            ),
            child: AppCachedNetworkImage(
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              imageUrl:
              'https://www.elsupplier.com/_next/image?url=https://portal.elsupplier.com/backend/public/storage/products/dark-chocolate-bar-732x549-thumbnail604108001.jpg&w=640&q=50',
            ),
          ),
          sliderSpace: 8,
          itemAspectRatio: 1.3,
          activeDotColor: colors.secondaryFixedDim,
          dotColor: colors.onPrimary,
        ),
      ],
    );
  }
}