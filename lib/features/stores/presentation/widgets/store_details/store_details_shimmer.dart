import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

class StoreDetailsShimmer extends StatelessWidget {
  const StoreDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          // Store info header: cover image + overlapping logo + description + info row
          AspectRatio(
            aspectRatio: 390 / 240,
            child: LayoutBuilder(
              builder: (context, con) {
                return Column(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, coverCon) => Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: AppShimmer(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.white,
                              ),
                              child: AppShimmer(
                                child: const CircleAvatar(radius: 28),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppShimmer(
                      child: Container(
                        width: con.maxWidth * 0.6,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    AppShimmer(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: List.generate(
                          3,
                          (index) => Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 5,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                width: con.maxWidth * 0.13,
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            color: colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: Column(
              spacing: 15,
              children: [
                // Banner slider
                AppShimmer(
                  child: AspectRatio(
                    aspectRatio: 3.4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // Brands slider: big brand name + image slider
                AppShimmer(
                  child: Column(
                    spacing: 8,
                    children: [
                      LayoutBuilder(
                        builder: (context, con) => Container(
                          width: double.infinity,
                          height: con.maxWidth * 0.18,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Brand info card: real card shape with skeleton lines inside
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(23),
                    decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: colors.black.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppShimmer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Container(
                            width: 90,
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Container(
                              width: 140,
                              height: 14,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            spacing: 20,
                            children: [
                              Column(
                                spacing: 6,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.black,
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Discount coupons horizontal list
                AppShimmer(
                  child: SizedBox(
                    height: 158,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: 3,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (_, _) => Container(
                        width: 121,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: AppBorderRadius.brCircular16,
                        ),
                      ),
                    ),
                  ),
                ),
                // Category circles list
                AppShimmer(
                  child: SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: 5,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, _) => SizedBox(
                        width: 80,
                        child: Column(
                          spacing: 8,
                          children: [
                            const CircleAvatar(radius: 40),
                            Container(
                              width: 60,
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Tab bar chips
                AppShimmer(
                  child: Row(
                    spacing: 12,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 55.0 + index * 20,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: AppBorderRadius.brCircular20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Products grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 16,
                    childAspectRatio: 170 / 280,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, _) => AppShimmer(
                    child: LayoutBuilder(
                      builder: (context, con) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 7,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: AppBorderRadius.brCircular16,
                              ),
                            ),
                          ),
                          Container(
                            width: con.maxWidth * 0.6,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: con.maxWidth * 0.35,
                                height: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.black,
                                ),
                              ),
                              CircleAvatar(radius: con.maxWidth * 0.08),
                            ],
                          ),
                        ],
                      ),
                    ),
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
