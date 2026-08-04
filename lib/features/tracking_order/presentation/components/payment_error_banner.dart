import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Red banner on the Payment Failed screen explaining why the charge failed
/// (declined card + error code), with a trailing info glyph.
class PaymentErrorBanner extends StatelessWidget {
  const PaymentErrorBanner({super.key});

  /// Pale-red banner fill — no equivalent in the theme [ColorScheme].
  static const Color _bannerBackground = Color(0xffFFF5F5);

  /// Pale-red banner border — no equivalent in the theme [ColorScheme].
  static const Color _bannerBorder = Color(0xffFEE2E2);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bannerBackground,
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: _bannerBorder),
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
                    color: colors.onError,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                6.hSpace,
                Text(
                  LangKeys.cardDeclinedBodyKey.tr(),
                  maxLines: 3,
                  style: AppTextStyles.style12Regular.copyWith(
                    color: colors.error,
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
