import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/caching/token_cache_service.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';










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
            SizedBox(
              width: size,
              height: size,
              child: _image(context),
            ),
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
      final int decodeSize =
          (size * MediaQuery.devicePixelRatioOf(context)).round();
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: size,
        height: size,


        cacheWidth: decodeSize,
        cacheHeight: decodeSize,


        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    final String? url = imageUrl;
    if (url != null && url.isNotEmpty) {
      final String token = TokenCacheService().getAccessToken() ?? '';
      return AppCachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,


        placeholderType: LoadingViewTypes.shimmer,
        httpHeaders: {'Authorization': 'Bearer $token'},
      );
    }

    return _placeholder();
  }

  Widget _placeholder() => Assets.media.images.png.userAvatarPlaceholderImg
      .image(fit: BoxFit.cover, width: size, height: size);
}
