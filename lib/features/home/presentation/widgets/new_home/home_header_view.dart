import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/animated_delivery_man_motorcycle_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_categories_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_search_field.dart';

class HomeHeaderView extends StatelessWidget {
  const HomeHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        return Stack(
          children: [
            ReverseWidget(
              applyReverse: !context.isRTL,
              child: Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Assets.media.images.svg.homeHeaderBackground.svg(
                  fit: BoxFit.cover,
                  width: con.maxWidth,
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  spacing: 10,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        spacing: 12,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LangKeys.homeGreetingKey.tr(),
                                    style: TextStyle(
                                      color: colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: con.maxWidth * 0.04,
                                    ),
                                  ),
                                  Row(
                                    spacing: 5,
                                    children: [
                                      Assets.media.images.svg.homeLocationIcon
                                          .svg(width: con.maxWidth * 0.05),
                                      Text(
                                        '7468 العليا، الرياض',
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          color: colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontSize: con.maxWidth * 0.03,
                                        ),
                                      ),
                                      RotatedBox(
                                        quarterTurns: 1,
                                        child: Assets
                                            .media
                                            .images
                                            .svg
                                            .arrowBrokenIcon
                                            .svg(width: con.maxWidth * 0.04),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Assets.media.images.svg.appLogos.homeWhiteAppLogo
                                  .svg(
                                    fit: BoxFit.contain,
                                    width: con.maxWidth * 0.3,
                                  ),
                            ],
                          ),
                          HomeSearchField(),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AnimatedDeliveryManMotorcycleView(),
                    ),
                    Expanded(flex: 4, child: HomeAppCategoriesView()),
                    Expanded(
                      flex: 1,
                      child: RepaintBoundary(
                        child: AnimatedSvgPicture.asset(
                          Assets.media.images.svg.viewAllArabic.path,
                          fit: BoxFit.contain,
                          playbackRate: 1,
                          autoPlay: true,
                          placeholderBuilder: (BuildContext context) =>
                              SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}