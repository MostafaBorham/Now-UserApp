import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/order_step_status.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The dot on a delivery-progress rail: a check for a done step, a haloed dot
/// for the current one, a small grey dot for one still ahead. Shared by Track
/// Order's timeline and the home live-orders strip so the two always agree.
class OrderStepMarker extends StatelessWidget {
  const OrderStepMarker({super.key, required this.status});

  final OrderStepStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    switch (status) {
      case OrderStepStatus.done:
        return Assets.media.images.svg.stepDone.svg(width: 22, height: 22);
      case OrderStepStatus.current:
        return Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary500Main.withValues(alpha: 0.18),
          ),
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary500Main,
            ),
          ),
        );
      case OrderStepStatus.pending:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.neutral200,
          ),
        );
    }
  }
}
