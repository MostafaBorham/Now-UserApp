import 'package:flutter/material.dart';

import '../../../assets/assets.gen.dart';

class WhiteAppLogo extends StatelessWidget {
  const WhiteAppLogo({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Assets.media.images.svg.whiteAppLogo.svg(
      fit: BoxFit.contain,
      width: size,
    );
  }
}