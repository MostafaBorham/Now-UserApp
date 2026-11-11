import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ReviewsFilterButton extends StatelessWidget {
  const ReviewsFilterButton({super.key, required this.size, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        radius: size,
        backgroundColor: colors.white,
        child: Center(
          child: Assets.media.images.svg.filter1Icon.svg(
            fit: BoxFit.contain,
            width: size,
            colorFilter: ColorFilter.mode(colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
