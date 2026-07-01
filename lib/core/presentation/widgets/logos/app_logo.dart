import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Assets.media.images.svg.appLogo.svg(
      fit: BoxFit.contain,
      width: size,
    );
  }
}
