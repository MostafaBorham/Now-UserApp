import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/extensions/order_status_palette.dart';




class TrackOrderNumberHeader extends StatelessWidget {
  const TrackOrderNumberHeader({
    super.key,
    this.orderNumber = 'ORD #458741',
    required this.status,
    this.statusLabel,
  });

  final String orderNumber;


  final OrderStatus status;


  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ({Color background, Color foreground}) statusPalette = status.palette(
      colors,
    );
    return IntrinsicHeight(
      child: Row(
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
                    color: colors.neutral500,
                  ),
                ),
                4.hSpace,
                Text(
                  orderNumber,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style18SemiBold.copyWith(
                    color: colors.black,
                  ),
                ),
              ],
            ),
          ),
          12.wSpace,


          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusPalette.background,
                borderRadius: AppBorderRadius.brCircular20,
              ),
              child: Text(
                statusLabel ?? LangKeys.pendingKey.tr(),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                style: AppTextStyles.style14Regular.copyWith(
                  color: statusPalette.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
