import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';


enum OrderStepStatus { done, current, pending }







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

  Widget _marker(BuildContext context) {
    final AppColorScheme colors = context.colors;
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
            color: colors.primary500Main.withValues(alpha: 0.18),
          ),
          child: Center(
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary500Main,
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
            color: colors.neutral200,
          ),
        );
    }
  }
}
