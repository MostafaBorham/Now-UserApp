import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class CircularCartButton extends StatelessWidget {
  const CircularCartButton({super.key, this.size});
  final double? size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      child: CircleAvatar(
        backgroundColor: colors.onPrimary,
        radius: size??25,
        child: Center(
          child: Assets.media.images.svg.shoppingCartIcon.svg(
            fit: BoxFit.contain,
            width: size??25,
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
