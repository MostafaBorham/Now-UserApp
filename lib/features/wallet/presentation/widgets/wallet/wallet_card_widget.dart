import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key, this.balance, this.onReload});




  final double? balance;




  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final BoxDecoration pillDecoration = BoxDecoration(
      borderRadius: AppBorderRadius.brCircular30,
      color: colors.white,
    );
    return Container(
      padding: EdgeInsets.all(20),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [colors.primary500Main, colors.primaryContainer],
        ),
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: LayoutBuilder(
        builder: (context, con) {





          final double pillWidth = con.maxWidth * 0.25;
          return Stack(
            children: [
              Assets.media.images.svg.nowWalletCard.svg(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  colors.primary500Main,
                  BlendMode.srcIn,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: pillWidth,
                        child: AspectRatio(
                          aspectRatio: 2.5,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: pillDecoration,




                            child: onReload != null
                                ? GestureDetector(
                                    onTap: onReload,
                                    behavior: HitTestBehavior.opaque,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Assets.media.images.svg.retryIcon
                                          .svg(
                                        colorFilter: ColorFilter.mode(
                                          colors.red400,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  )
                                : balance == null
                                    ? null
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${formatDouble(balance)}',
                                          style: AppTextStyles.style20SemiBold
                                              .copyWith(
                                            color: colors.primary700,
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      FittedBox(
                        child: Text(
                          LangKeys.nowCreditKey.tr(),
                          style: AppTextStyles.style14Medium.copyWith(
                            color: colors.white,
                          ),
                        ),
                      ),
                    ],
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
                          child: Assets.media.images.svg.appOrangeLogo.svg(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
