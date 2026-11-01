import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

/// Circular profile avatar.
///
/// Renders, in priority order: a locally-picked [imageFile] (edit preview), the
/// remote [imageUrl], or the circular user placeholder. The remote avatar lives
/// on a private disk, so the request carries the user's bearer token.
///
/// When [showCameraOverlay] is true a translucent strip with a camera icon is
/// drawn over the lower part of the circle (the "change photo" affordance on
/// the edit screen), tappable via [onCameraTap].
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.size = 112,
    this.imageUrl,
    this.imageFile,
    this.showCameraOverlay = false,
    this.onCameraTap,
  });

  final double size;
  final String? imageUrl;
  final File? imageFile;
  final bool showCameraOverlay;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          children: [
            SizedBox(width: size, height: size, child: _image(context)),
            if (showCameraOverlay)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size * 0.42,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onCameraTap,
                  child: Container(
                    color: context.colors.black.withValues(alpha: 0.4),
                    alignment: Alignment.center,
                    child: Assets.media.images.svg.camera.svg(
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _image(BuildContext context) {
    if (imageFile != null) {
      final int decodeSize = (size * MediaQuery.devicePixelRatioOf(context))
          .round();
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        // A camera photo is many megapixels; decoding it at full resolution for
        // a ~112px circle costs tens of MB of image memory for nothing.
        cacheWidth: decodeSize,
        cacheHeight: decodeSize,
        // The picked file can be gone by the time we paint (the OS reclaiming a
        // gallery temp file); fall back to the placeholder rather than throwing.
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    final String? url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return AppCachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.fill,
        // Shimmer (not a spinner) while the picture downloads; the app-wide
        // no-image placeholder shows if the request fails.
        placeholderType: LoadingViewTypes.shimmer,
        httpHeaders: _authHeaders(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() => Assets.media.images.png.userAvatarPlaceholderImg
      .image(fit: BoxFit.cover, width: size, height: size);
}

Map<String, String> _authHeaders() => {
  'Authorization': 'Bearer ${TokenCacheService().getAccessToken() ?? ''}',
};

/// Shows the remote avatar at [imageUrl] full screen on black, pinch-to-zoom.
/// A tap anywhere, the close button or back dismisses it.
Future<void> showProfileAvatarFullScreen(
  BuildContext context,
  String imageUrl,
) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: context.colors.black,
    builder: (BuildContext dialogContext) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: dialogContext.pop,
            child: InteractiveViewer(
              maxScale: 4,
              child: AppCachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                // A full-screen shimmer would flash white over the black.
                placeholderType: LoadingViewTypes.circular,
                circularProgressSize: 32,
                errorBackgroundColor: Colors.transparent,
                httpHeaders: _authHeaders(),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: MediaQuery.paddingOf(dialogContext).top + 8,
          end: 8,
          child: IconButton(
            onPressed: dialogContext.pop,
            tooltip: MaterialLocalizations.of(dialogContext).closeButtonTooltip,
            icon: Icon(Icons.close, color: dialogContext.colors.white),
          ),
        ),
      ],
    ),
  );
}
