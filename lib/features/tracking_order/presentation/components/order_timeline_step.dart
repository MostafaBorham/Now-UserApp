import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// State of a single delivery-timeline step.
enum OrderStepStatus { done, current, pending }

/// One row of the delivery timeline: a left rail (connector line + status
/// marker), the step's illustrated icon and its label.
///
/// [topLineColor] / [bottomLineColor] are supplied by the parent section so the
/// connector reflects overall progress (green for reached segments, grey
/// otherwise); [isFirst] / [isLast] hide the connector past the ends.
class OrderTimelineStep extends StatelessWidget {
  const OrderTimelineStep({
    super.key,
    required this.status,
    required this.icon,
    required this.title,
    required this.topLineColor,
    required this.bottomLineColor,
    this.isFirst = false,
    this.isLast = false,
  });

  final OrderStepStatus status;
  final Widget icon;
  final String title;
  final Color topLineColor;
  final Color bottomLineColor;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Expanded(
                  child: _connector(isFirst ? Colors.transparent : topLineColor),
                ),
                _marker(context),
                Expanded(
                  child: _connector(isLast ? Colors.transparent : bottomLineColor),
                ),
              ],
            ),
          ),
          12.wSpace,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: icon,
          ),
          12.wSpace,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  title,
                  maxLines: 2,
                  style: AppTextStyles.style14Medium.copyWith(
                    color: status == OrderStepStatus.pending
                        ? colors.onSurface
                        : colors.onSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placed inside an [Expanded], so the tight vertical constraint stretches the
  // line to fill the gap; the parent column centres its 2px width on the rail.
  Widget _connector(Color color) => Container(width: 2, color: color);

  Widget _marker(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    switch (status) {
      case OrderStepStatus.done:
        return Assets.media.images.svg.stepDone.svg(
          width: 22,
          height: 22,
        );
      case OrderStepStatus.current:
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.18),
          ),
          child: Center(
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
            ),
          ),
        );
      case OrderStepStatus.pending:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surfaceContainerLow,
          ),
        );
    }
  }
}
