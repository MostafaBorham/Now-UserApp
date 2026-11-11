import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class DetailsTopBarCurtain extends StatelessWidget {
  const DetailsTopBarCurtain({super.key, required this.isShown});

  final bool isShown;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isShown ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      curve: isShown ? Curves.easeOut : Curves.easeIn,
      builder: (_, double progress, Widget? child) => progress == 0
          ? const SizedBox.shrink()
          : FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: progress,
              child: child,
            ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.white,
          border: Border(
            bottom: BorderSide(color: colors.neutral200, width: 1),
          ),
        ),
      ),
    );
  }
}
