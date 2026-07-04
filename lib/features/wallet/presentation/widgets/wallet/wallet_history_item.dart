import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/home/home_interface.dart';

class WalletHistoryItem extends StatelessWidget {
  const WalletHistoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, con) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(con.maxWidth * 0.1),
          ),
          child: Row(
            spacing: 15,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  spacing: 12,
                  children: [
                    CircularBrandLogo(
                      radius: con.maxWidth * 0.07,
                      logoUrl:
                          'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                      backgroundColor: colors.onPrimary,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shaworma',
                            style: AppTextStyles.style14SemiBold.copyWith(
                              color: colors.onSecondary,
                              fontSize: con.maxWidth * 0.04,
                            ),
                          ),
                          Text(
                            '${LangKeys.expiredKey.tr()} 26-04-2026',
                            style: AppTextStyles.style12Regular.copyWith(
                              color: colors.onPrimaryFixed.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: con.maxWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 3.5,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.brCircular30,
                    ),
                    child: Center(
                      child: Text(
                        LangKeys.refundedKey.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style12Medium.copyWith(
                          color: colors.errorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  spacing: 5,
                  children: [
                    Assets.media.images.svg.realSaudiCurrency.svg(
                      fit: BoxFit.contain,
                      width: con.maxWidth * 0.04,
                      colorFilter: ColorFilter.mode(
                        colors.error,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      '-10',
                      style: AppTextStyles.style16SemiBold.copyWith(
                        color: colors.error,
                        fontSize: con.maxWidth * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
