import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
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

  /// URL → when it last failed. A failed URL shows the placeholder at once
  /// rather than being fetched again on every rebuild — but only for
  /// [_failedUrlTtl]. It used to be held for the whole session, so an image
  /// that failed once (a hiccup, a cover not uploaded yet) never showed until a
  /// restart (BUG-021).
  /// ponytail: one fixed back-off; per-URL exponential back-off if a bad URL
  /// ever floods the logs.
  static final Map<String, DateTime> _failedUrls = <String, DateTime>{};

  static const int _maxFailedUrls = 200;

  static const Duration _failedUrlTtl = Duration(seconds: 60);

  @visibleForTesting
  static void rememberFailedUrl(String url) {
    _failedUrls.remove(url);
    if (_failedUrls.length >= _maxFailedUrls) {
      _failedUrls.remove(_failedUrls.keys.first);
    }
    _failedUrls[url] = DateTime.now();
  }

  @visibleForTesting
  static bool recentlyFailed(String url, {DateTime? now}) {
    final DateTime? failedAt = _failedUrls[url];
    if (failedAt == null) return false;
    if ((now ?? DateTime.now()).difference(failedAt) < _failedUrlTtl) {
      return true;
    }
    _failedUrls.remove(url);
    return false;
  }

  static bool _watchingConnection = false;

  static void _clearFailedUrlsOnReconnect() {
    if (_watchingConnection) return;
    _watchingConnection = true;
    ConnectionChecker.connectionStream().listen((status) {
      if (status == InternetConnectionStatus.connected) _failedUrls.clear();
    });
  }

  static bool _isFinite(double? size) => size != null && size.isFinite;

  static int? _cacheDimension(double logicalSize, double devicePixelRatio) {
    if (!logicalSize.isFinite || logicalSize <= 0) return null;
    return (logicalSize * devicePixelRatio).round();
  }

  /// Decode size for a [boxWidth]×[boxHeight] box: its longer side × DPR, the
  /// other axis left to follow the image's own aspect ratio — passing both
  /// would squash the image into the box's shape (`ResizeImage`'s exact
  /// policy). Exact for any image no wider than its box (no taller, for a tall
  /// box); a wider one cover-cropped into it comes out slightly soft.
  static (int?, int?) _cacheSize(
    double boxWidth,
    double boxHeight,
    double devicePixelRatio,
  ) {
    final int? w = _cacheDimension(boxWidth, devicePixelRatio);
    final int? h = _cacheDimension(boxHeight, devicePixelRatio);
    if (w == null || h == null) return (w, h);
    return w >= h ? (w, null) : (null, h);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinite(width) && _isFinite(height)) {
      return _buildForBox(context, width!, height!);
    }
    // Without a finite size, decode for the box the parent lays out — or every
    // caller that fills its parent decodes at the uploaded resolution.
    return LayoutBuilder(
      builder: (context, constraints) => _buildForBox(
        context,
        _isFinite(width) ? width! : constraints.maxWidth,
        _isFinite(height) ? height! : constraints.maxHeight,
      ),
    );
  }

  Widget _buildForBox(BuildContext context, double boxWidth, double boxHeight) {
    final AppColorScheme colors = context.colors;
    final (int? memCacheWidth, int? memCacheHeight) = _cacheSize(
      boxWidth,
      boxHeight,
      MediaQuery.devicePixelRatioOf(context),
    );

    final Widget errorPlaceholder = Container(
      width: width ?? double.infinity,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: errorBackgroundColor ?? colors.onPrimaryContainer,
      ),
      // Figma "failed to load image" (User-App 12803:42671 / 12867:11679).
      // Scaled down, never overflowing, in slots smaller than its own size.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 7.04,
          children: <Widget>[
            Assets.media.images.svg.imageErrorPlaceholder.svg(
              width: 51.38,
              height: 51.37,
            ),
            Text(
              LangKeys.failedToLoadImageKey.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.style10Medium.copyWith(
                fontSize: 10.565,
                height: 14.09 / 10.565,
                color: colors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );

    if (imageUrl.isEmpty || recentlyFailed(imageUrl)) {
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
        rememberFailedUrl(url);
        _clearFailedUrlsOnReconnect();
        return errorPlaceholder;
      },
    );
  }
}
