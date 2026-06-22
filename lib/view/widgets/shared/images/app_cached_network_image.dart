import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:shimmer/shimmer.dart';

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: colors.onSurface.withValues(alpha: 0.6),
        highlightColor: colors.onSurface.withValues(alpha: 0.3),
        child: Container(
          width: double.infinity,
          color: colors.onPrimary,
        ),
      ),
      errorWidget: (_, _, _) =>
          Assets.media.images.svg.noImagePlaceholder.svg(fit: BoxFit.cover),
    );
  }
}
