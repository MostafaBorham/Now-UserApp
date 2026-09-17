import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Container(
            color: colors.neutral400,
            height: 1,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(LangKeys.orKey.tr(),
            style: textThemes.bodyLarge?.copyWith(
              color: colors.neutral400,
              fontWeight: FontWeight.w500
          )),
        ),
        Expanded(
          child: Container(
            color: colors.neutral400,
            height: 1,
          ),
        ),
      ],
    );
  }
}