import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';



class OrderConfirmedHeader extends StatelessWidget {
  const OrderConfirmedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [



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
