import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';



class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderType = LoadingViewTypes.shimmer,
    this.circularProgressSize,
    this.httpHeaders,
    this.errorBackgroundColor,
  });

  final String imageUrl;
  final double? width;
  final double? circularProgressSize;
  final double? height;
  final BoxFit fit;
  final LoadingViewTypes? placeholderType;
  final Color? errorBackgroundColor;



  final Map<String, String>? httpHeaders;






  static final Set<String> _failedUrls = <String>{};

  static const int _maxFailedUrls = 200;

  static void _rememberFailedUrl(String url) {
    if (_failedUrls.length >= _maxFailedUrls) {
      _failedUrls.remove(_failedUrls.first);
    }
    _failedUrls.add(url);
  }




  static bool _watchingConnection = false;

  static void _clearFailedUrlsOnReconnect() {
    if (_watchingConnection) return;
    _watchingConnection = true;
    ConnectionChecker.connectionStream().listen((status) {
      if (status == InternetConnectionStatus.connected) _failedUrls.clear();
    });
  }

  int? _cacheDimension(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null ||
        logicalSize.isInfinite ||
        logicalSize <= 0) {
      return null;
    }
    return (logicalSize * devicePixelRatio).round();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final int? memCacheWidth = _cacheDimension(width, devicePixelRatio);
    final int? memCacheHeight = _cacheDimension(height, devicePixelRatio);

    final Widget errorPlaceholder = Container(
      width: width ?? double.infinity,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: errorBackgroundColor ?? colors.onPrimaryContainer,
      ),
      child: Assets.media.images.png.noImageAvail.image(
        fit: BoxFit.contain,
        height: double.infinity,
        width: double.infinity,
      ),
    );



    if (imageUrl.isEmpty || _failedUrls.contains(imageUrl)) {
      return errorPlaceholder;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: httpHeaders,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      imageBuilder: (context, imageProvider) => Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Image(
            image: ResizeImage.resizeIfNeeded(
              memCacheWidth,
              memCacheHeight,
              imageProvider,
            ),
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) {
        switch (placeholderType) {
          case LoadingViewTypes.circular:
            return Center(
              child: SizedBox(
                width: circularProgressSize ?? ((width ?? 30) * 0.7),
                height: circularProgressSize ?? ((width ?? 30) * 0.7),
                child: CircularProgressIndicator(color: colors.primary500Main),
              ),
            );
          case LoadingViewTypes.shimmer || null:
            return AppShimmer(
              child: Container(
                width: width ?? double.infinity,
                height: height ?? double.infinity,
                color: colors.white,
              ),
            );
        }
      },
      errorWidget: (_, url, _) {
        _rememberFailedUrl(url);
        _clearFailedUrlsOnReconnect();
        return errorPlaceholder;
      },
    );
  }
}
