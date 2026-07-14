import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

class StoreDetailsShimmer extends StatelessWidget {
  const StoreDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          AppShimmer(
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(color: Colors.black),
                      ),
                      Container(color: Colors.transparent, height: 80),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: LayoutBuilder(
                      builder: (context, con) {
                        return Column(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(radius: 35),
                            Container(
                              width: con.maxWidth * 0.6,
                              height: 14,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              width: con.maxWidth * 0.5,
                              height: 14,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black,
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
          ),
          Container(
            color: colors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 35),
            width: double.infinity,
            child: Column(
              spacing: 15,
              children: [
                AppShimmer(
                  child: AspectRatio(
                    aspectRatio: 2.8,
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
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          5,
                          (index) =>
                              CircleAvatar(radius: con.maxWidth * 0.07),
                        ),
                      );
                    },
                  ),
                ),
                AppShimmer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: AspectRatio(
                      aspectRatio: 1.3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                AppShimmer(
                  child: Row(
                    spacing: 10,
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: AspectRatio(
                          aspectRatio: 2.5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AppShimmer(
                  child: LayoutBuilder(
                    builder: (context, con) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          4,
                          (index) => Column(
                            spacing: 5,
                            children: [
                              CircleAvatar(radius: con.maxWidth * 0.08),
                              Container(
                                width: con.maxWidth * 0.12,
                                height: con.maxWidth * 0.025,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
