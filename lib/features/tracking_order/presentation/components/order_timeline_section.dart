import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';

import 'order_timeline_step.dart';

/// "Track Order" progress section: the estimated-time header followed by the
/// four-step delivery timeline. The step illustrations already encode their
/// active/inactive state, so this widget only drives the rail markers & the
/// connector colours from each step's [OrderStepStatus].
class OrderTimelineSection extends StatelessWidget {
  const OrderTimelineSection({
    super.key,
    this.estimatedTime = '1 Hour - 40 Minutes',
  });

  final String estimatedTime;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color reached = colors.primary;
    final Color pending = TrackingOrderColors.timelinePending;

    final List<_TimelineStepData> steps = [
      _TimelineStepData(
        status: OrderStepStatus.done,
        icon: Assets.media.images.svg.orderAccepted.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.orderAcceptedKey.tr(),
      ),
      _TimelineStepData(
        status: OrderStepStatus.current,
        icon: Assets.media.images.svg.orderConfirmed.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.orderConfirmedBeingPreparedKey.tr(),
      ),
      _TimelineStepData(
        status: OrderStepStatus.pending,
        icon: Assets.media.images.svg.onTheWay.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.onTheWayToYouKey.tr(),
      ),
      _TimelineStepData(
        status: OrderStepStatus.pending,
        icon: Assets.media.images.svg.delivered.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.deliveredKey.tr(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LangKeys.trackOrderKey.tr(),
              style: AppTextStyles.style16SemiBold.copyWith(
                color: colors.onSecondary,
              ),
            ),
            const Spacer(),
            8.wSpace,
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${LangKeys.estimatedDeliveryTimeKey.tr()}  ',
                      style: AppTextStyles.style10Regular.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: estimatedTime,
                      style: AppTextStyles.style10SemiBold.copyWith(
                        color: colors.onSecondary,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        16.hSpace,
        ...List.generate(steps.length, (i) {
          final bool prevReached =
              i > 0 && steps[i - 1].status == OrderStepStatus.done;
          final bool reachedFromHere = steps[i].status == OrderStepStatus.done;
          return OrderTimelineStep(
            status: steps[i].status,
            icon: steps[i].icon,
            title: steps[i].title,
            isFirst: i == 0,
            isLast: i == steps.length - 1,
            topLineColor: prevReached ? reached : pending,
            bottomLineColor: reachedFromHere ? reached : pending,
          );
        }),
      ],
    );
  }
}

class _TimelineStepData {
  const _TimelineStepData({
    required this.status,
    required this.icon,
    required this.title,
  });

  final OrderStepStatus status;
  final Widget icon;
  final String title;
}
