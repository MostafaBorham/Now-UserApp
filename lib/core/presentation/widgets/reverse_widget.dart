import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';

class ReverseWidget extends StatelessWidget {
  const ReverseWidget({
    super.key,
    required this.child, this.applyReverse,
  });

  final bool? applyReverse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return applyReverse??context.isRTL? Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scaleByDouble(-1.0, 1.0, 1.0, 1),
      child: child,
    ) : child;
  }
}