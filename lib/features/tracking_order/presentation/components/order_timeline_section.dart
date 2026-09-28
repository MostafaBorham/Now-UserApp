import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/enums/order_step_status.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

import 'order_timeline_step.dart';

/// "Track Order" progress section: the estimated-time header followed by the
/// four-step delivery timeline. The step illustrations already encode their
/// active/inactive state, so this widget only drives the rail markers & the
/// connector colours from each step's [OrderStepStatus], which the order's live
/// [status] reports through [OrderStatus.stepStatusAt].
class OrderTimelineSection extends StatelessWidget {
  const OrderTimelineSection({
    super.key,
    this.status = const PendingStatus(),
    this.estimatedTime = '',
  });

  /// The order's current lifecycle state, mapped onto the four milestones.
  final OrderStatus status;
  final String estimatedTime;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color reached = colors.primary500Main;
    final Color pending = colors.neutral200;

    final List<_TimelineStepData> steps = [
      _TimelineStepData(
        status: status.stepStatusAt(0),
        icon: Assets.media.images.svg.orderAccepted.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.orderAcceptedKey.tr(),
      ),
      _TimelineStepData(
        status: status.stepStatusAt(1),
        icon: Assets.media.images.svg.orderConfirmed.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.orderConfirmedBeingPreparedKey.tr(),
      ),
      _TimelineStepData(
        status: status.stepStatusAt(2),
        icon: Assets.media.images.svg.onTheWay.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.onTheWayToYouKey.tr(),
      ),
      _TimelineStepData(
        status: status.stepStatusAt(3),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          children: [
            Text(
              LangKeys.trackOrderKey.tr(),
              style: AppTextStyles.style16SemiBold.copyWith(
                color: colors.black,
              ),
            ),
            // Customer checkout never sets an ETA, so there usually isn't one.
            if (estimatedTime.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: [
                  Text(
                    LangKeys.estimatedDeliveryTimeKey.tr(),
                    style: AppTextStyles.style10Regular.copyWith(
                      color: colors.neutral1200,
                    ),
                  ),
                  Text(
                    estimatedTime,
                    style: AppTextStyles.style10SemiBold.copyWith(
                      color: colors.black,
                    ),
                  ),
                ],
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
