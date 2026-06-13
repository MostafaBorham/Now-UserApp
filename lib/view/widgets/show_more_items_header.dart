import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../common/localization/lang_keys.dart';
import '../styles/text_styles.dart';

class ShowMoreItemsHeader extends StatelessWidget {
  const ShowMoreItemsHeader({super.key, required this.headerTitle});

  final String headerTitle;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AutoSizeText(
          headerTitle,
          style: AppTextStyles.style20SemiBold.copyWith(
            color: colors.onSecondary,
          ),
        ),
        AutoSizeText(
          LangKeys.showMoreKey.tr(),
          style: AppTextStyles.style12SemiBold.copyWith(
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}
