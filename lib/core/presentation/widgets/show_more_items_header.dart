import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ShowMoreItemsHeader extends StatelessWidget {
  const ShowMoreItemsHeader({super.key, required this.headerTitle, this.onMore});

  final String headerTitle;

  final GestureTapCallback? onMore;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context,con) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              headerTitle,
              style: AppTextStyles.style18SemiBold.copyWith(
                color: colors.onSecondary,
                fontSize: con.maxWidth*0.05
              ),
            ),
            InkWell(
              onTap: onMore,
              child: Text(
                LangKeys.showMoreKey.tr(),
                style: AppTextStyles.style14SemiBold.copyWith(
                  color: colors.primary,
                    fontSize: con.maxWidth*0.035
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
