import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class CircularBrandLogo extends StatelessWidget {
  const CircularBrandLogo({
    super.key,
    required this.radius,
    required this.logoUrl,
    this.backgroundColor,
    this.elevation = 0,
  });

  final double radius;
  final String logoUrl;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      elevation: elevation!,
      shape: CircleBorder(),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? colors.onPrimaryContainer,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            fit: BoxFit.contain,
            width: radius,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: radius * 0.7,
                height: radius * 0.7,
                child: CircularProgressIndicator(
                  color: colors.primary,
                  strokeWidth: radius * 0.1,
                ),
              ),
            ),
            errorWidget: (context, url, error) => FractionallySizedBox(
              widthFactor: 2,
              heightFactor: 2,
              child: Assets.media.images.png.noImageAvail.image(
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
