import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/placeholder_types.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';

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
    this.placeholderType = PlaceholderTypes.shimmer, this.circularProgressSize,
  });

  final String imageUrl;
  final double? width;
  final double? circularProgressSize;
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
            return Center(child: SizedBox(
                width: circularProgressSize?? ((width??30)*0.7),
                height: circularProgressSize?? ((width??30)*0.7),
                child: CircularProgressIndicator(color: colors.primary,)));
          case PlaceholderTypes.shimmer || null:
            return AppShimmer(
              child: Container(width: double.infinity,height: double.infinity, color: colors.onPrimary),
            );
        }
      },
      errorWidget: (_, _, _) =>
          Container(
              width: width?? double.infinity,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              height: height?? double.infinity,
              decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.3),
              ),
              child: Assets.media.images.png.noImageAvail.image(fit: BoxFit.contain,height: double.infinity,width: double.infinity)),
    );
  }
}