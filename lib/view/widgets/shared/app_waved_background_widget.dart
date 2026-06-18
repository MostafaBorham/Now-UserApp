import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';

import 'clippers/wave_clipper.dart';

class AppWavedBackgroundWidget extends StatelessWidget {
  const AppWavedBackgroundWidget({
    super.key,
    required this.body,
    required this.appBar,
  });

  final Widget body;
  final Widget appBar;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        fit: StackFit.passthrough,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: colors.secondary,
            alignment: Alignment.center,
            child: SafeArea(
              bottom: false,
              child: AutoSizeText('data'),
            ),
          ),
          Assets.media.images.png.waveClipBackground.image(fit: BoxFit.fill),
        ],
      ),
    );
  }
}
