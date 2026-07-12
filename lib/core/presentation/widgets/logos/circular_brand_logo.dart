import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/placeholder_types.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class CircularBrandLogo extends StatelessWidget {
  const CircularBrandLogo({
    super.key,
    required this.radius,
    required this.logoUrl,
    this.backgroundColor, this.elevation = 0,
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
      clipBehavior: Clip.antiAlias,
      shape: CircleBorder(
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? colors.onPrimaryContainer,
        child: Center(
          child: AppCachedNetworkImage(
            height: radius,
            width: radius,
            imageUrl: logoUrl,
            fit: BoxFit.contain,
            placeholderType: PlaceholderTypes.circular,
          ),
        ),
      ),
    );
  }
}
