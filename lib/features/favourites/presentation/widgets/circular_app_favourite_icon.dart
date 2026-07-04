import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

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
