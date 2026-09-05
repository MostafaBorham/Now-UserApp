import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Success header of the Order Confirmed screen: the green check inside a soft
/// halo, followed by the confirmation title and supporting copy.
class OrderConfirmedHeader extends StatelessWidget {
  const OrderConfirmedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // `order_done.svg` draws the 96px circle inside a 156px canvas, so it
        // carries its own ~30px halo/shadow margin — that stands in for the
        // design's 24px of padding above and below the check circle.
        Assets.media.images.svg.orderDone.svg(),
        Text(
          LangKeys.orderConfirmedTitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style16Bold.copyWith(color: colors.neutral1200),
        ),
        8.hSpace,
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            LangKeys.orderConfirmedSubtitleKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 3,
            style: AppTextStyles.style12Regular.copyWith(
              color: colors.outline,
              height: 22.75 / 12,
            ),
          ),
        ),
      ],
    );
  }
}
