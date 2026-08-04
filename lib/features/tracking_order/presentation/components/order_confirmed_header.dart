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
        16.hSpace,
        Row(
          mainAxisAlignment: .center,
          children: [
            // CircleBackButton(),
            Assets.media.images.svg.orderDone.svg(),
          ],
        ),
        16.hSpace,
        Text(
          LangKeys.orderConfirmedTitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style18Bold.copyWith(color: colors.onSecondary),
        ),
        8.hSpace,
        Text(
          LangKeys.orderConfirmedSubtitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 3,
          style: AppTextStyles.style14Regular.copyWith(color: colors.onSurface),
        ),
      ],
    );
  }
}
