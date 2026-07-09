import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';

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
              color: AppColors.avatarPlaceholder,
              child: Image.asset(
                'assets/svg/person.png',
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
                    color: AppColors.avatarOverlay,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svg/camera.svg',
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
