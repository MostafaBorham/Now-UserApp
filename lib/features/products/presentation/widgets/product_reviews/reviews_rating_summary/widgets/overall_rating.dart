import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/svg_tint.dart';

class OverallRating extends StatelessWidget {
  const OverallRating({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Assets.media.images.svg.starIcon.svg(
              width: 16,
              height: 16,
              colorMapper: SvgTint(colors.surface),
            ),
            Text(
              '${formatDouble(4.8)}',
              style: AppTextStyles.style32Bold.copyWith(
                color: colors.neutral1000,
                height: 1.2,
              ),
            ),
          ],
        ),
        Text(
          LangKeys.fromReviewsCountKey.tr(
            namedArgs: <String, String>{'count': '1200'},
          ),
          textAlign: TextAlign.center,
          style: AppTextStyles.style14Regular.copyWith(
            color: colors.neutral500,
          ),
        ),
      ],
    );
  }
}
