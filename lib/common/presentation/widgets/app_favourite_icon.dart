import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';

class AppFavouriteIcon extends StatelessWidget {
  const AppFavouriteIcon({super.key, this.size = 10, this.isFavourite = false});
  final double? size;
  final bool? isFavourite;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      elevation: 1,
      shape: const CircleBorder(),
      child: CircleAvatar(
        radius: size,
        backgroundColor: colors.onPrimary,
        child:
        (isFavourite!
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
          width: size,
          colorFilter: ColorFilter.mode(
            isFavourite!
                ? colors.errorContainer
                : colors.onTertiaryFixed,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
