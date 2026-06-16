import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';

class AppWavedScaffold extends StatelessWidget {
  const AppWavedScaffold({super.key, required this.body, required this.appBar});

  final Widget body;
  final Widget appBar;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                colors.onPrimary,
                colors.onSecondaryFixed,
              ],
              stops: [0.2, 1.0],
              transform: GradientRotation(0),
            ),
          ),
          child: Column(
            spacing: 20,
            children: [
              appBar,
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Assets.media.images.svg.whiteWaveBackground.svg(
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    color: colors.onPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
