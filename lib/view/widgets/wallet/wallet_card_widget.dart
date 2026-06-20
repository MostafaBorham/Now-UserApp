import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 1.8,
      child: Container(
        padding: EdgeInsets.all(30),
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
              spacing: 15,
              children: [
                Row(
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
                    AutoSizeText(
                      'Now Credit',
                      style: AppTextStyles.style14Medium.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Spacer(),
                Container(
                  width: double.infinity,
                  height: 3,
                  color: colors.onSecondaryFixed,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    /*AutoSizeText(
                      '1213 1231 1232',
                      style: AppTextStyles.style18Medium.copyWith(
                        color: colors.onPrimary,
                      ),
                    ),*/
                    Assets.media.images.svg.appOrangeLogo.svg(
                        width: 85.sp
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
