import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/app_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_search_field.dart';

class HomeHeaderView extends StatelessWidget {
  const HomeHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context,con) {
        return Stack(
          children: [
            ReverseWidget(
              applyReverse: !context.isRTL,
              child: Assets.media.images.svg.homeHeaderBackground.svg(
                fit: BoxFit.cover,
                width: con.maxWidth
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('hala wallah .. naortna!',style: TextStyle(
                            color: colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: con.maxWidth*0.04
                          ),),
                          Row(
                            spacing: 5,
                            children: [
                              Assets.media.images.svg.homeLocationIcon.svg(
                                width: con.maxWidth*0.05
                              ),
                              Text('olya , saudi arabia 2321',style: TextStyle(
                                  color: colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: con.maxWidth*0.03
                              ),),
                             RotatedBox(
                               quarterTurns: 1,
                                child: Assets.media.images.svg.arrowBrokenIcon.svg(
                                  width: con.maxWidth*0.04
                                ),
                              ),

                            ],
                          )
                        ],
                      ),
                      Assets.media.images.svg.appOrangeLogo.svg(
                        fit: BoxFit.contain,
                        width: con.maxWidth*0.3
                      ),
                    ],
                  ),
                  HomeSearchField()
                ],
              ),
            )
          ],
        );
      }
    );
  }
}