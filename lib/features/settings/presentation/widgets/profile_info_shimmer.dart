import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

/// Loading placeholder for [ProfileInfo]: a circular block the exact size of the
/// avatar plus a short bar where the name will appear, both masked by the app
/// shimmer. Shown while the profile is being fetched so the default avatar never
/// flashes before the real picture and name arrive.
class ProfileInfoShimmer extends StatelessWidget {
  const ProfileInfoShimmer({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    final Color block = context.colors.white;

    return AppShimmer(
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: block, shape: BoxShape.circle),
          ),
          const SizedBox(height: 14),
          Container(
            width: 160,
            height: 28,
            decoration: BoxDecoration(
              color: block,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
