import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class OffersPatternBackground extends StatelessWidget {
  const OffersPatternBackground({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, con) {
            final double tileHeight = con.maxWidth * 100 / 388;
            final ScrollController? controller = scrollController;
            final Widget tiles = RepaintBoundary(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    (con.maxHeight / tileHeight).ceil() + 1,
                    (_) => ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 100 / 105,
                        child: Assets
                            .media
                            .images
                            .svg
                            .homeNeverMissOffersBackground
                            .svg(width: con.maxWidth, fit: BoxFit.fitWidth),
                      ),
                    ),
                  ),
                ),
              ),
            );
            if (controller == null) return tiles;
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  -((controller.hasClients ? controller.offset : 0) %
                      tileHeight),
                ),
                child: child,
              ),
              child: tiles,
            );
          },
        ),
      ),
    );
  }
}
