import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_view_all_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/product_item3_view.dart';

class HomeAppCategorySectionView extends StatelessWidget {
  const HomeAppCategorySectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: ReverseWidget(
            applyReverse: !context.isRTL,
            child: Assets.media.images.svg.oneWaveBackground.svg(
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(colors.onInverseSurface.withValues(alpha: 0.2),BlendMode.srcIn)
            ),
          ),
        ),
        Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Electronics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.black,
                    ),
                  ),
                  HomeViewAllWidget(
                    size: 15,
                    startBackgroundColor: colors.onInverseSurface.withValues(
                      alpha: 0.5,
                    ),
                    endBackgroundColor: colors.onInverseSurface.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsetsDirectional.only(
                  start: 16
                ),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ProductItem3View();
                },
                separatorBuilder: (context, index) => 4.wSpace,
                itemCount: 5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}