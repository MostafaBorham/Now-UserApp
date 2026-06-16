import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularBrandLogo extends StatelessWidget {
  const CircularBrandLogo({
    super.key, required this.radius, required this.logoUrl,
  });

  final double radius;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.onPrimaryContainer,
      child: Center(child: CachedNetworkImage(height: radius*1.5,imageUrl: logoUrl,fit: BoxFit.contain,)),
    );
  }
}