import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast_type.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';








class AppToastCard extends StatelessWidget {
  const AppToastCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
  });

  final AppToastType type;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color accent = switch (type) {
      AppToastType.error => colors.red300Main,
      AppToastType.success => colors.primary500Main,
    };
    final SvgGenImage icon = switch (type) {
      AppToastType.error => Assets.media.images.svg.errorToastIcon,
      AppToastType.success => Assets.media.images.svg.successToastIcon,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.symmetric(
          vertical: BorderSide(color: accent, width: 2.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: icon.svg(width: 32, height: 32)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: AppTextStyles.style14SemiBold.copyWith(
                    color: colors.neutral1200,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 3,
                  style: AppTextStyles.style12Regular.copyWith(
                    color: colors.neutral400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
