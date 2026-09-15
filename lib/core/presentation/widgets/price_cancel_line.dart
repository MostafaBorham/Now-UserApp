import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class PriceCancelLine extends StatelessWidget {
  const PriceCancelLine({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: child,
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: double.infinity,
                  height: 2,
                  color: colors.neutral400,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}
