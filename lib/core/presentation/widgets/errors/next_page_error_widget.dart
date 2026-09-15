import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';







class NextPageErrorWidget extends StatelessWidget {
  const NextPageErrorWidget({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Center(
      child: IconButton(
        onPressed: onRetry,
        tooltip: LangKeys.retryKey.tr(),
        iconSize: 40,
        icon: Assets.media.images.svg.retryIcon.svg(
          width: 40,
          colorFilter: ColorFilter.mode(colors.onError, BlendMode.srcIn),
        ),
      ),
    );
  }
}
