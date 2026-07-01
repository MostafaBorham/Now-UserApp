import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_app_prefix_icon_button.dart';

class ServerConnectionErrorWidget extends StatelessWidget {
  const ServerConnectionErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Assets.media.images.svg.serverFailIcon.svg(width: 300.w),
          AutoSizeText(
            LangKeys.serverConnectionFailedKey.tr(),
            style: AppTextStyles.style24Bold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          AutoSizeText(
            LangKeys.unableToReachServersKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style16Regular,
          ),
                15.hSpace,
                PrimaryAppPrefixIconButton(title: LangKeys.retryKey.tr(),onTap: () {

          },prefixIcon: Assets.media.images.svg.retryIcon.svg(colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn)),)
        ],
      ),
    );
  }
}
