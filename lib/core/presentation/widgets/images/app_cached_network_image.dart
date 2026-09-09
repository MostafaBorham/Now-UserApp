import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
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
    final AppColorScheme colors = context.colors;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) {
        switch (placeholderType) {
          case PlaceholderTypes.circular:
            return Center(child: CircularProgressIndicator(color: colors.primary500Main));
          case PlaceholderTypes.shimmer || null:
            return Shimmer.fromColors(
              baseColor: colors.neutral500.withValues(alpha: 0.6),
              highlightColor: colors.neutral500.withValues(alpha: 0.3),
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

  /// Headers forwarded to the image request — needed for auth-protected
  /// images (e.g. the private-disk profile avatar, which requires the bearer).
  final Map<String, String>? httpHeaders;

  /// URLs that already failed to load once this session. cached_network_image
  /// does not cache failures, so it re-hits the network on every rebuild — which
  /// during fast scrolling flashes the shimmer placeholder back over the error
  /// image before failing again. Remembering the failed URL lets us render the
  /// error image straight away, with no retry and no shimmer flash.
  static final Set<String> _failedUrls = <String>{};

  /// Guards the one-time subscription that clears [_failedUrls] on reconnect,
  /// so a URL that failed only because the device was offline is retried once
  /// connectivity is back instead of staying broken for the whole session.
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

    // Skip CachedNetworkImage entirely for empty or known-bad URLs: no request
    // is made, so no placeholder/shimmer can flash on rebuild.
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
        // Installed on the first failure rather than on every build: with
        // nothing in [_failedUrls] there is nothing for a reconnect to clear,
        // so an app whose images all load never opens the subscription at all.
        _clearFailedUrlsOnReconnect();
        return errorPlaceholder;
      },
    );
  }
}
