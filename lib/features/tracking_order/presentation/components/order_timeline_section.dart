import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

import 'order_timeline_step.dart';

/// "Track Order" progress section: the estimated-time header followed by the
/// four-step delivery timeline. The step illustrations already encode their
/// active/inactive state, so this widget only drives the rail markers & the
/// connector colours from each step's [OrderStepStatus], derived here from the
/// order's live [status].
class OrderTimelineSection extends StatelessWidget {
  const OrderTimelineSection({
    super.key,
    this.status = const PendingStatus(),
    this.estimatedTime = '',
  });

  /// The order's current lifecycle state, mapped onto the four milestones.
  final OrderStatus status;
  final String estimatedTime;

  /// The milestone the order is currently working toward — the step that shows
  /// the active (green-circle) marker; every step before it is already done
  /// (checkmark). `accepted` and `preparing` sit on the "confirmed & being
  /// prepared" milestone, while `ready` advances to "on the way" (the order is
  /// prepared and waiting for pickup) and `on_the_way` advances to the final
  /// "delivered" milestone. Terminal / unknown states park at the first
  /// milestone (they aren't tracked here — the section is hidden for them).
  int get _reachedMilestone => switch (status) {
    PendingStatus() => 0,
    AcceptedStatus() || PreparingStatus() => 1,
    ReadyStatus() => 2,
    OnTheWayStatus() || DeliveredStatus() => 3,
    _ => 0,
  };

  OrderStepStatus _stepStatus(int index) {
    if (index < _reachedMilestone) return OrderStepStatus.done;
    if (index > _reachedMilestone) return OrderStepStatus.pending;
    // The reached milestone is the active one, unless the order is delivered:
    // its final step is complete, not in-progress.
    return status is DeliveredStatus
        ? OrderStepStatus.done
        : OrderStepStatus.current;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color reached = colors.primary500Main;
    final Color pending = colors.neutral200;

    final List<_TimelineStepData> steps = [
      _TimelineStepData(
        status: _stepStatus(0),
        icon: Assets.media.images.svg.orderAccepted.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.orderAcceptedKey.tr(),
      ),
      _TimelineStepData(
        status: _stepStatus(1),
        icon: Assets.media.images.svg.orderConfirmed.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.orderConfirmedBeingPreparedKey.tr(),
      ),
      _TimelineStepData(
        status: _stepStatus(2),
        icon: Assets.media.images.svg.onTheWay.svg(
          width: 34,
          height: 34,
        ),
        title: LangKeys.onTheWayToYouKey.tr(),
      ),
      _TimelineStepData(
        status: _stepStatus(3),
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
