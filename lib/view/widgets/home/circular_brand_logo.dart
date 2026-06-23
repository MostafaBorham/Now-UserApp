import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/enums/placeholder_types.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/images/app_cached_network_image.dart';

class CircularBrandLogo extends StatelessWidget {
  const CircularBrandLogo({
    super.key,
    required this.radius,
    required this.logoUrl,
    this.backgroundColor,
  });

  final double radius;
  final String logoUrl;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? colors.onPrimaryContainer,
      child: Center(
        child: AppCachedNetworkImage(
          height: radius,
          imageUrl: logoUrl,
          fit: BoxFit.contain,
          placeholderType: PlaceholderTypes.circular,
        ),
      ),
    );
  }
}
