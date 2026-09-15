import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class OutOfStockLabel extends StatelessWidget {
  const OutOfStockLabel({super.key, this.fontSize});

  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: AppBorderRadius.brCircular8,
      ),
      child: Text(
        LangKeys.outOfStockKey.tr(),
        style: AppTextStyles.style12Medium.copyWith(
          color: colors.white,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
