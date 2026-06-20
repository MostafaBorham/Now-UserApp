import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/theme/app_gradient_colors.dart';
import 'package:simple_animated_rating_bar/simple_animated_rating_bar.dart';
import 'package:simple_animated_rating_bar/utils/arb_type.dart';

class RatingCard extends StatelessWidget {
  const RatingCard({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.brCircular14,
        border: Border.all(
          color: colors.primary,
          width: 1.5,
        ),
      ),
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
           Text(
            title,
            style: AppTextStyles.style18Medium.copyWith(
              color: colors.onSecondary
            ),
          ),
          Text(
            'Your rate help us for enhance our service',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppTextStyles.style14Regular.copyWith(
                color: colors.onSurface
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppGradientColors.gradient1,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
            'Good 😍',
              textDirection: TextDirection.rtl,
              style: AppTextStyles.style14Regular.copyWith(
                color: colors.onSecondary
              ),
            ),
          ),

          AnimatedRatingBar(
            animationType: ARBAnimationType.bounce,
            emptyWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Assets.media.images.svg.orderStarRate.svg(
                width: 20.sp,
                colorFilter: ColorFilter.mode(colors.inversePrimary.withValues(alpha: 0.3), BlendMode.srcIn)
              ),
            ),
            fullWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Assets.media.images.svg.orderStarRate.svg(
                  width: 20.sp,
                  colorFilter: ColorFilter.mode(colors.surface, BlendMode.srcIn)
              ),
            ),
            initialValue: 4,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          /*AnimatedRatingBar(
            activeFillColor: colors.surface,
            strokeColor: Colors.transparent,
            initialRating: 0,
            height: 60,
            width: MediaQuery.of(context).size.width,
            animationColor: Colors.red,
            onRatingUpdate: (rating) {
              debugPrint(rating.toString());
            },
          ),*/

          /*Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star_rounded, color: Color(0xFFF2B01E), size: 30),
              SizedBox(width: 4),
              Icon(Icons.star_rounded, color: Color(0xFFF2B01E), size: 30),
              SizedBox(width: 4),
              Icon(Icons.star_rounded, color: Color(0xFFF2B01E), size: 30),
              SizedBox(width: 4),
              Icon(Icons.star_rounded, color: Color(0xFFF2B01E), size: 30),
              SizedBox(width: 4),
              Icon(Icons.star_rounded, color: Color(0xFFD9D9D9), size: 30),
            ],
          ),*/
        ],
      ),
    );
  }
}