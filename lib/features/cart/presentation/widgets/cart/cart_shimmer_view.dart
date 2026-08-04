import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Skeleton placeholder mirroring the cart screen's loaded layout — a list of
/// 3 collapsed [CartBrandItemCard]s plus the bottom checkout button — meant to
/// be rendered inside an [AppShimmer] while the cart is loading.
class CartShimmerView extends StatelessWidget {
  const CartShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return AppShimmer(
      child: Column(
        spacing: 20,
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(3),
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 20,
                    children: [
                      // Logo + store name expansion header.
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          12.wSpace,
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
      
                      // Collapsed products images preview.
                      Row(
                        spacing: 8,
                        children: [
                          for (int i = 0; i < 3; i++)
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                        ],
                      ),
      
                      // Total + checkout pill.
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => 20.hSpace,
              itemCount: 3,
            ),
          ),
      
          PrimaryAppButton(
            title: 'Checkout',
          ),
        ],
      ),
    );
  }
}
