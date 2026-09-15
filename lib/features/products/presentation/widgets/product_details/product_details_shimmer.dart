import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      // Mirror the real view's top offset so the shimmer sits under the wave at
      // the same height instead of jumping up when the data resolves.
      padding: const EdgeInsets.only(top: 57),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          spacing: 16,
          children: [
            AppShimmer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Placeholder for the real ProductDiscountTicket: a plain
                  // block tilted with the exact same rotation. The SizedBox
                  // reserves the tilted block's bounding box (a 55x35 tag turned
                  // 65° spans ~55x65) so the whole shape stays inside the shimmer
                  // gradient's paint bounds — otherwise the overflowing corners
                  // render as a static color instead of shimmering.
                  SizedBox(
                    width: 55,
                    height: 65,
                    child: Center(
                      child: Transform.rotate(
                        angle: -65 * math.pi / 180,
                        child: Container(
                          width: 55,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const CircleAvatar(radius: 20, backgroundColor: Colors.black),
                ],
              ),
            ),
            AppShimmer(
              child: AspectRatio(
                aspectRatio: 2,
                child: Column(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    AnimatedSmoothIndicator(
                      activeIndex: 0,
                      count: 3,
                      effect: WormEffect(
                        dotHeight: 10,
                        dotWidth: 10,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppShimmer(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            AppShimmer(
              child: LayoutBuilder(
                builder: (context, con) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        width: con.maxWidth * 0.25,
                        height: con.maxWidth * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: List.generate(
                          4,
                          (index) => Column(
                            spacing: 5,
                            children: [
                              CircleAvatar(radius: con.maxWidth * .06),
                              Container(
                                color: Colors.black,
                                width: con.maxWidth * 0.1,
                                height: con.maxWidth * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            AppShimmer(
              child: LayoutBuilder(
                builder: (context, con) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        width: con.maxWidth * 0.25,
                        height: con.maxWidth * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: List.generate(
                          4,
                          (index) => Expanded(
                            child: AspectRatio(
                              aspectRatio: 2.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            AppShimmer(
              child: LayoutBuilder(
                builder: (context, con) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        width: con.maxWidth * 0.25,
                        height: con.maxWidth * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            AppShimmer(
              child: LayoutBuilder(
                builder: (context, con) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Container(
                        width: con.maxWidth * 0.25,
                        height: con.maxWidth * 0.05,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              color: Colors.grey,
              width: double.infinity,
              height: 1,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            AppShimmer(
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    flex: 2,
                    child: PrimaryAppPrefixIconButton(
                      title: LangKeys.addToCartKey.tr(),
                      buttonPadding: 10,
                      buttonRadius: 8,
                      prefixIcon: Assets.media.images.svg.shoppingCartIcon
                          .svg(
                        width: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PrimaryAppButton(
                      title: '',
                      buttonPadding: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
