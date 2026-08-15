import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class CircularBrandLogo extends StatelessWidget {
  const CircularBrandLogo({
    super.key,
    required this.radius,
    required this.logoUrl,
    this.backgroundColor,
    this.elevation = 0,
    this.logoScale = 0.7,
  });

  final double radius;
  final String logoUrl;
  final Color? backgroundColor;
  final double? elevation;

  /// Width of the logo itself as a multiple of [radius].
  final double logoScale;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Material(
      elevation: elevation!,
      shape: CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? colors.onPrimaryContainer,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            fit: BoxFit.contain,
            width: radius * logoScale,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: radius * 0.7,
                height: radius * 0.7,
                child: CircularProgressIndicator(
                  color: colors.primary500Main,
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
