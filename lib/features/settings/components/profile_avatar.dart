import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Circular avatar built from the provided `person.png` placeholder.
///
/// When [showCameraOverlay] is true a translucent strip with a camera icon is
/// drawn over the lower part of the circle (the "change photo" affordance on
/// the edit screen).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.size = 112,
    this.showCameraOverlay = false,
    this.onCameraTap,
  });

  final double size;
  final bool showCameraOverlay;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          children: [
            Container(
              width: size,
              height: size,
              color: context.colors.neutral200,
              child: Assets.media.images.svg.personPng.image(
                fit: BoxFit.cover,
                width: size,
                height: size,
              ),
            ),
            if (showCameraOverlay)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size * 0.42,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCameraTap,
                  child: Container(
                    color: context.colors.black.withValues(alpha: 0.4),
                    alignment: Alignment.center,
                    child: Assets.media.images.svg.camera.svg(
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
