import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Shows [image] full screen on black, pinch-to-zoom. A tap anywhere, the
/// close button or back dismisses it. [image] should fit itself
/// (`BoxFit.contain`); it is given the whole screen.
Future<void> showFullScreenImage(BuildContext context, Widget image) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    barrierColor: context.colors.black,
    builder: (BuildContext dialogContext) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: dialogContext.pop,
            child: InteractiveViewer(maxScale: 4, child: image),
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
