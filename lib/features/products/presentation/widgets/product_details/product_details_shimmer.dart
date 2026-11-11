import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_images_header.dart';

class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key, required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        spacing: 16,
        children: [
          ProductImagesHeader(
            viewportSize: MediaQuery.sizeOf(context),
            topPadding: topPadding,
            fadeProgress: const AlwaysStoppedAnimation<double>(0),
            child: const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              spacing: 16,
              children: [
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
              ],
            ),
          ),

          Container(color: Colors.grey, width: double.infinity, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppShimmer(
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    flex: 2,
                    child: PrimaryAppButton(
                      title: LangKeys.addToCartKey.tr(),
                      buttonRadius: 8,
                      prefixIcon: Assets.media.images.svg.shoppingCartIcon.svg(
                        width: 20,
                      ),
                    ),
                  ),
                  Expanded(child: PrimaryAppButton(title: '')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
