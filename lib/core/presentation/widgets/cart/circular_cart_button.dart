import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class CircularCartButton extends StatelessWidget {
  const CircularCartButton({super.key, this.size, this.onTap});
  final double? size;

  final GestureTapCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: colors.white,
        radius: size??25,
        child: Center(
          child: Assets.media.images.svg.shoppingCartIcon.svg(
            fit: BoxFit.contain,
            width: size??25,
            colorFilter: ColorFilter.mode(
              colors.black,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
