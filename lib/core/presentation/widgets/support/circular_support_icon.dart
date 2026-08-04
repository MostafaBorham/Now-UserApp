import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class CircularSupportIcon extends StatelessWidget {
  const CircularSupportIcon({super.key, this.size, this.onTap});
  final double? size;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        backgroundColor: colors.onPrimary,
        radius: size ?? 25,
        child: Center(
          child: Assets.media.images.svg.supportCallIcon.svg(
            fit: BoxFit.contain,
            width: size ?? 25,
            colorFilter: ColorFilter.mode(
              colors.onSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
