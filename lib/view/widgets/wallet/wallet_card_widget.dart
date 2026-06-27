import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [colors.primary, colors.primaryContainer],
        ),
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Stack(
        children: [
          Assets.media.images.svg.nowWalletCard.svg(
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              colors.primary,
              BlendMode.srcIn,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AspectRatio(
                aspectRatio: 11 ,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.brCircular30,
                        color: colors.onPrimary,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 12,
                      ),
                      child: AutoSizeText(
                        '10.00',
                        style: AppTextStyles.style20SemiBold.copyWith(
                          color: colors.onPrimaryFixedVariant,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        LangKeys.nowCreditKey.tr(),
                        style: AppTextStyles.style14Medium.copyWith(
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
              AspectRatio(
                aspectRatio: 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 2.5,
                      color: colors.onSecondaryFixed,
                    ),
                    AspectRatio(
                      aspectRatio: 15,
                      child: Assets.media.images.svg.appOrangeLogo.svg(
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
