import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Container(
            color: colors.inversePrimary,
            height: 1,
          ),
        ),
        AutoSizeText(LangKeys.orKey.tr(),
          style: textThemes.bodyLarge?.copyWith(
            color: colors.inversePrimary,
            fontWeight: FontWeight.w500
        ),minFontSize: 10,),
        Expanded(
          child: Container(
            color: colors.inversePrimary,
            height: 1,
          ),
        ),
      ],
    );
  }
}