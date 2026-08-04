import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Top row of the Track Order screen: the order glyph, the order number and a
/// status chip. Uses the same status-chip styling as the orders list.
class TrackOrderNumberHeader extends StatelessWidget {
  const TrackOrderNumberHeader({
    super.key,
    this.orderNumber = 'ORD #458741',
    this.status,
  });

  final String orderNumber;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Row(
      children: [
        Assets.media.images.svg.order.svg(width: 48, height: 48),
        12.wSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LangKeys.orderNumberKey.tr(),
                style: AppTextStyles.style12Medium.copyWith(
                  color: colors.onSurface,
                ),
              ),
              4.hSpace,
              Text(
                orderNumber,
                style: AppTextStyles.style18SemiBold.copyWith(
                  color: colors.onSecondary,
                ),
              ),
            ],
          ),
        ),
        12.wSpace,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.onSecondaryFixed.withValues(alpha: 0.4),
            borderRadius: AppBorderRadius.brCircular20,
          ),
          child: Text(
            status ?? LangKeys.pendingKey.tr(),
            style: AppTextStyles.style12Medium.copyWith(
              color: colors.onErrorContainer,
            ),
          ),
        ),
      ],
    );
  }
}
