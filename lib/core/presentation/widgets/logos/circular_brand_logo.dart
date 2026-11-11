import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class CircularBrandLogo extends StatelessWidget {
  const CircularBrandLogo({
    super.key,
    required this.radius,
    required this.logoUrl,
    this.backgroundColor,
    this.elevation = 0,
    this.logoScale = 1.1,
    this.fit = BoxFit.contain,
    this.borderSide = BorderSide.none,
  });

  final double radius;
  final String? logoUrl;
  final Color? backgroundColor;
  final double? elevation;

  /// Width of the logo itself as a multiple of [radius]: 2 with
  /// [BoxFit.cover] fills the circle, so a square logo reads as round.
  final double logoScale;

  final BoxFit fit;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color background = backgroundColor ?? colors.onPrimaryContainer;
    final String? url = logoUrl?.trim();
    final Uri? uri = (url == null || url.isEmpty) ? null : Uri.tryParse(url);
    final bool hasValidUrl =
        uri != null && uri.hasScheme && uri.host.isNotEmpty;
    final double logoSize = radius * logoScale;
    return Material(
      elevation: elevation!,
      shape: CircleBorder(side: borderSide),
      clipBehavior: Clip.antiAlias,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: background,
        child: Center(
          // An empty URL shows the "failed to load image" placeholder.
          child: AppCachedNetworkImage(
            imageUrl: hasValidUrl ? url! : '',
            fit: fit,
            width: logoSize,
            height: logoSize,
            placeholderType: LoadingViewTypes.circular,
            circularProgressSize: radius * 0.7,
            errorBackgroundColor: background,
          ),
        ),
      ),
    );
  }
}
