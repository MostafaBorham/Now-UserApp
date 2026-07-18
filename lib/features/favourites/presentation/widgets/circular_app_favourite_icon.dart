import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/caching/cache_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/welcome/data/datasources/local/cache/welcome_cache_service.dart';

class CircularAppFavouriteIcon extends StatefulWidget {
  const CircularAppFavouriteIcon({super.key, this.size = 20, this.isFavourite = false, required this.onFavouriteChanged});
  final double? size;
  final bool? isFavourite;
  final Function(bool) onFavouriteChanged;

  @override
  State<CircularAppFavouriteIcon> createState() => _CircularAppFavouriteIconState();
}

class _CircularAppFavouriteIconState extends State<CircularAppFavouriteIcon> {
  late bool tmpFavourite;

  @override
  void initState() {
    super.initState();
    tmpFavourite = widget.isFavourite!;
  }
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        final Map<String, dynamic> tokenData =
            WelcomeCacheService().getToken();
        final bool isGuest =
            tokenData[CacheKeys.isGuest] as bool? ?? true;

        if (isGuest) {
          context.pushNamed(AppRoutes.phoneVerificationScreen);
          return;
        }

        tmpFavourite = !tmpFavourite;
        widget.onFavouriteChanged.call(tmpFavourite);
        setState(() {});
      },
      child: Material(
        elevation: 1,
        shape: const CircleBorder(),
        child: CircleAvatar(
          radius: widget.size,
          backgroundColor: colors.onPrimary,
          child:
          (tmpFavourite
              ? Assets
              .media
              .images
              .svg
              .filledFavouriteIcon
              : Assets
              .media
              .images
              .svg
              .favouriteIcon)
              .svg(
            width: widget.size,
            colorFilter: ColorFilter.mode(
              tmpFavourite
                  ? colors.errorContainer
                  : colors.onTertiaryFixed,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
