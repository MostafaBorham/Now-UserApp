import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_arrow_slider.dart';

class StoreDetailsBrandsSlider extends StatelessWidget {
  const StoreDetailsBrandsSlider({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      children: [
        Stack(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'GALAXY',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 90,
                  color: colors.secondaryFixedDim,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                    AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [
                      colors.white.withValues(
                        alpha: 0.9,
                      ),
                      colors.white.withValues(
                        alpha: 0.75,
                      ),
                      colors.white.withValues(
                        alpha: 0.5,
                      ),
                      colors.white.withValues(
                        alpha: 0.3,
                      ),
                      colors.white.withValues(
                        alpha: 0.1,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                      .withValues(alpha: 0.3),
                  offset: Offset(0, 10),
                  spreadRadius: 15,
                  blurRadius: 25,
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
          itemAspectRatio: 1.5,
          activeDotColor: colors.secondaryFixedDim,
          dotColor: colors.white,
        ),
      ],
    );
  }
}