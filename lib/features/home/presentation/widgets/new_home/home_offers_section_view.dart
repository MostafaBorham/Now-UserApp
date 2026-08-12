import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class HomeOffersSectionView extends StatelessWidget {
  const HomeOffersSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        return SizedBox(
          width: con.maxWidth,
          child: Stack(
            children: [
              Positioned(
                bottom: 12,
                height: con.maxWidth*0.6,
                width: con.maxWidth,
                child: Assets.media.images.svg.homeOffersBackground.svg(
                  fit: BoxFit.fill,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 32,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          'Special Offers',
                          style: TextStyle(
                            fontSize: con.maxWidth * 0.05,
                            color: colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: con.maxWidth * 0.4,
                          child: ListView.separated(
                            padding: EdgeInsetsDirectional.only(end: 10),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => AspectRatio(
                              aspectRatio: 0.7,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadiusGeometry.circular(18),
                                ),
                              ),
                            ),
                            separatorBuilder: (context, index) => 12.wSpace,
                            itemCount: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 3,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadiusGeometry.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: colors.black.withValues(alpha: 0.25),
                            offset: Offset.zero,
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
