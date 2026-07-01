import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/enums/placeholder_types.dart';
import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';
import 'package:shimmer/shimmer.dart';

/*class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderType = PlaceholderTypes.shimmer,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final PlaceholderTypes? placeholderType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) {
        switch (placeholderType) {
          case PlaceholderTypes.circular:
            return Center(child: CircularProgressIndicator(color: colors.primary));
          case PlaceholderTypes.shimmer || null:
            return Shimmer.fromColors(
              baseColor: colors.onSurface.withValues(alpha: 0.6),
              highlightColor: colors.onSurface.withValues(alpha: 0.3),
              child: Container(width: double.infinity, color: colors.onPrimary),
            );
        }
      },
      errorWidget: (_, _, _) =>
          Assets.media.images.svg.noImagePlaceholder.svg(fit: BoxFit.cover),
    );
  }
}*/

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderType = PlaceholderTypes.shimmer,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final PlaceholderTypes? placeholderType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      imageBuilder: (context, imageProvider) => Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Image(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) {
        switch (placeholderType) {
          case PlaceholderTypes.circular:
            return Center(child: CircularProgressIndicator(color: colors.primary));
          case PlaceholderTypes.shimmer || null:
            return Shimmer.fromColors(
              baseColor: colors.onSurface.withValues(alpha: 0.6),
              highlightColor: colors.onSurface.withValues(alpha: 0.3),
              child: Container(width: double.infinity,height: double.infinity, color: colors.onPrimary),
            );
        }
      },
      errorWidget: (_, _, _) =>
          Assets.media.images.svg.noImagePlaceholder.svg(fit: BoxFit.cover,height: double.infinity,width: double.infinity),
    );
  }
}