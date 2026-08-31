import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_arrow_slider.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_brand_info_card.dart';

class StoreDetailsBrandsSlider extends StatelessWidget {
  const StoreDetailsBrandsSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return AppArrowSlider(
      // Each page stacks as one column that swipes together: wordmark, then the
      // image, then the full-width details card — the card spans the page width
      // so it matches the design and never overflows inside the arrow gutters.
      aboveImage: ShaderMask(
        // The wordmark is painted with the design's diagonal white-to-brand
        // gradient, so it fades in from the left. Left-to-right in both locales —
        // the word itself is always latin.
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.08, 0.63],
          colors: [
            colors.white.withValues(alpha: 0.8),
            colors.secondaryFixedDim,
          ],
        ).createShader(bounds),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'GALAXY',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 72,
                letterSpacing: -4,
                height: 1,
                color: colors.secondaryFixedDim,
              ),
            ),
          ),
        ),
      ),
      sliderItem: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusGeometry.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.secondaryFixedDim.withValues(alpha: 0.4),
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
      belowImage: const StoreDetailsBrandInfoCard(),
      sliderSpace: 8,
      itemHeight: 620,
      activeDotColor: colors.secondaryFixedDim,
      dotColor: colors.neutral200,
    );
  }
}
