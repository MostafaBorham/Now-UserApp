import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_themes.dart';

/// Red banner on the Payment Failed screen explaining why the charge failed
/// (declined card + error code), with a trailing info glyph.
class PaymentErrorBanner extends StatelessWidget {
  const PaymentErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TrackingOrderColors.errorBannerBackground,
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: TrackingOrderColors.errorBannerBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.cardDeclinedTitleKey.tr(),
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: TrackingOrderColors.errorBannerTitle,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                6.hSpace,
                Text(
                  LangKeys.cardDeclinedBodyKey.tr(),
                  maxLines: 3,
                  style: AppTextStyles.style12Regular.copyWith(
                    color: TrackingOrderColors.errorBannerBody,
                  ),
                ),
              ],
            ),
          ),
          12.wSpace,
          Assets.media.images.svg.infoRed.svg(),
        ],
      ),
    );
  }
}
