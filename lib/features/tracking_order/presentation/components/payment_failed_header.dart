import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Failure header of the Payment Failed screen: the red error mark inside a
/// soft halo, followed by the failure title and reassurance copy.
class PaymentFailedHeader extends StatelessWidget {
  const PaymentFailedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: .center,
          children: [
            // CircleBackButton(),
            Assets.media.images.svg.paymentNotComplete.svg(),
          ],
        ),
        16.hSpace,
        Text(
          LangKeys.paymentNotCompletedKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.style20Bold.copyWith(
            color: colors.black,
            fontSize: 22,
          ),
        ),
        8.hSpace,
        Text(
          LangKeys.paymentFailedSubtitleKey.tr(),
          textAlign: TextAlign.center,
          maxLines: 3,
          style: AppTextStyles.style14Regular.copyWith(
            color: Color(0xff666666),
          ),
        ),
      ],
    );
  }
}
