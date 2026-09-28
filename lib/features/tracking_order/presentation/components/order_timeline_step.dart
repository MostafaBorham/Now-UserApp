import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/enums/order_step_status.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/orders/order_step_marker.dart';

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
    final AppColorScheme colors = context.colors;
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
                OrderStepMarker(status: status),
                Expanded(
                  child: _connector(isLast ? Colors.transparent : bottomLineColor),
                ),
              ],
            ),
          ),
          12.wSpace,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),


            child: status == OrderStepStatus.pending
                ? ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: icon,
                  )
                : icon,
          ),
          12.wSpace,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  title,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style14Medium.copyWith(
                    color: status == OrderStepStatus.pending
                        ? colors.neutral500
                        : colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _connector(Color color) => Container(width: 2, color: color);
}
