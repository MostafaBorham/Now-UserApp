import 'package:flutter/material.dart';

class PriceCancelLine extends StatelessWidget {
  const PriceCancelLine({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: child,
        ),
        /// الخط المائل
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: double.infinity,
                  height: 2,
                  color: colors.inversePrimary,
                ),
              ),
            ),
          ),
        ),
/*        Transform.rotate(
          angle: -0.3,
          child: Container(width: 60, height: 1.5, color: colors.inversePrimary),
        ),*/
      ],
    );
  }
}
