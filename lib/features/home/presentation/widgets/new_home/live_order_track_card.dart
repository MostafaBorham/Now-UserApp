import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/order_step_status.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/orders/order_step_marker.dart';

/// One in-flight order on the home live-orders strip: the store's logo, the
/// minutes left until the estimate, and the order's four delivery milestones.

class LiveOrderTrackCard extends StatelessWidget {
  const LiveOrderTrackCard({
    super.key,
    this.remainingMinutes,
    required this.logoUrl,
    required this.steps,
    this.onTap,
  });

  /// Minutes left until the estimated delivery; `null` when the order has no
  /// estimate, which leaves the line out rather than inventing one.
  final int? remainingMinutes;
  final String logoUrl;
  final List<(String, OrderStepStatus)> steps;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary500Main),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.flip(
                flipX: !context.isRTL,
                child: Assets.media.images.svg.liveOrderCardBackground.svg(
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircularBrandLogo(radius: 20, logoUrl: logoUrl),
                      const SizedBox(width: 8),
                      if (remainingMinutes != null)
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${LangKeys.estimatedDeliveryTimeKey.tr()} ',
                                  style: TextStyle(color: colors.neutral1200),
                                ),
                                TextSpan(
                                  text:
                                      '$remainingMinutes ${LangKeys.minutesKey.tr()}',
                                  style: TextStyle(
                                    color: colors.primary500Main,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < steps.length; i++) ...[
                        if (i > 0)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: steps[i - 1].$2 == OrderStepStatus.done
                                      ? colors.primary500Main
                                      : colors.neutral200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox.square(
                              dimension: 22,
                              child: Center(
                                child: OrderStepMarker(status: steps[i].$2),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              steps[i].$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: steps[i].$2 == OrderStepStatus.pending
                                    ? colors.neutral500
                                    : colors.neutral1200,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
