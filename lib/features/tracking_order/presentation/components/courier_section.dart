import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';




class CourierSection extends StatelessWidget {
  const CourierSection({
    super.key,
    this.courierName = 'Panda Store',
    this.logoUrl = '',
    this.onChat,
    this.onCall,
  });

  final String courierName;
  final String logoUrl;
  final VoidCallback? onChat;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
        borderRadius: AppBorderRadius.brCircular16,
      ),
      child: Row(
        children: [
          CircularBrandLogo(
            radius: 24,
            logoUrl: logoUrl,
            backgroundColor: colors.white,
          ),
          12.wSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LangKeys.courierKey.tr(),
                  style: AppTextStyles.style16SemiBold.copyWith(
                    color: colors.black,
                  ),
                ),
                2.hSpace,
                Text(
                  courierName,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              InkWell(
                onTap: onCall,
                customBorder: const CircleBorder(),
                child: Assets.media.images.svg.call.svg(width: 40, height: 40),
              ),
              InkWell(
                onTap: onChat,
                customBorder: const CircleBorder(),
                child: Assets.media.images.svg.chat.svg(width: 40, height: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
