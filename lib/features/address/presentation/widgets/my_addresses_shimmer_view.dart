import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Full loading view for the "My Address" screen.
///
/// Self-contained: renders a non-scrolling list of [AddressCardShimmer]
/// placeholders wrapped in [AppShimmer], so the screen only needs to place
/// a single instance of this widget in its loading branch.
class MyAddressesShimmerView extends StatelessWidget {
  const MyAddressesShimmerView({super.key, this.itemCount = 4});

  /// Number of shimmer cards to render.
  final int itemCount;

  static const double _cardGap = 16;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      spacing: 16,
      children: [
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, _) => const SizedBox(height: _cardGap),
          itemBuilder: (_, _) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1 — radio + title + edit slot.
                AppShimmer(
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth*0.04,
                        height: screenWidth*0.04,
                        decoration: BoxDecoration(
                          color: colors.onSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.onSurface),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: screenWidth*0.04,
                        width: screenWidth*0.15,
                        decoration: BoxDecoration(
                          color: colors.onSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Spacer(),
                      Container(
                        width: screenWidth*0.05,
                        height: screenWidth*0.05,
                        decoration: BoxDecoration(
                          color: colors.onSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppShimmer(
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth*0.04,
                        height: screenWidth*0.04,
                        decoration: BoxDecoration(
                          color: colors.onSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: colors.onSecondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AppShimmer(child: PrimaryAppButton(title: 'add new adesss',buttonPadding: 16,))
      ],
    );
  }
}
