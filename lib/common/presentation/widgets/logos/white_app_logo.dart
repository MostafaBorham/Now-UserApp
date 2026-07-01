import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/common/presentation/assets/assets.gen.dart';

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