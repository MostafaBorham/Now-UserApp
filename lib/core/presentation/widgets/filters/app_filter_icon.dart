import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class AppFilterIcon extends StatelessWidget {
  const AppFilterIcon({super.key, this.size = 20});
  final double? size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: colors.tertiary.withValues(alpha: 0.3),
      radius: size,
      child: Assets.media.images.svg.filterIcon.svg(width: size),
    );
  }
}
