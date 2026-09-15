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
    this.logoScale = 1.1,
  });

  final double radius;
  final String? logoUrl;
  final Color? backgroundColor;
  final double? elevation;


  final double logoScale;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final String? url = logoUrl?.trim();
    final Uri? uri = (url == null || url.isEmpty) ? null : Uri.tryParse(url);
    final bool hasValidUrl =
        uri != null && uri.hasScheme && uri.host.isNotEmpty;
    final Widget noImage = FractionallySizedBox(
      widthFactor: 2,
      heightFactor: 2,
      child: Assets.media.images.png.noImageAvail.image(
        fit: BoxFit.contain,
      ),
    );
    return Material(
      elevation: elevation!,
      shape: CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? colors.onPrimaryContainer,
        child: Center(
          child: !hasValidUrl
              ? noImage
              : CachedNetworkImage(
                  imageUrl: url!,
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
                  errorWidget: (context, url, error) => noImage,
                ),
        ),
      ),
    );
  }
}
