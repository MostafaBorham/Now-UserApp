import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            'Server connection failed',
            style: AppTextStyles.style24Bold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          AutoSizeText(
            'Unable to reach the servers. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: AppTextStyles.style16Regular,
          ),
                15.hSpace,
                PrimaryAppPrefixIconButton(title: 'Retry',onTap: () {

          },prefixIcon: Assets.media.images.svg.retryIcon.svg(colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn)),)
        ],
      ),
    );
  }
}
