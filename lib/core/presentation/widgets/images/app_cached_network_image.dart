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
  });

  final String imageUrl;
  final double? width;
  final double? circularProgressSize;
  final double? height;
  final BoxFit fit;
  final LoadingViewTypes? placeholderType;



  final Map<String, String>? httpHeaders;






  static final Set<String> _failedUrls = <String>{};




  static bool _watchingConnection = false;

  static void _clearFailedUrlsOnReconnect() {
    if (_watchingConnection) return;
    _watchingConnection = true;
    ConnectionChecker.connectionStream().listen((status) {
      if (status == InternetConnectionStatus.connected) _failedUrls.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final Widget errorPlaceholder = Container(
      width: width ?? double.infinity,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
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
      imageBuilder: (context, imageProvider) => Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Image(image: imageProvider, fit: fit),
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
                width: double.infinity,
                height: height,
                color: colors.white,
              ),
            );
        }
      },
      errorWidget: (_, url, _) {
        _failedUrls.add(url);



        _clearFailedUrlsOnReconnect();
        return errorPlaceholder;
      },
    );
  }
}
