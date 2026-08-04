import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class AppFilterIcon extends StatelessWidget {
  const AppFilterIcon({super.key, this.size = 20, this.onTap});
  final double? size;
  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap:
          onTap,
      child: CircleAvatar(
        backgroundColor: colors.tertiary.withValues(alpha: 0.3),
        radius: size,
        child: Assets.media.images.svg.filterIcon.svg(width: size),
      ),
    );
  }
}
