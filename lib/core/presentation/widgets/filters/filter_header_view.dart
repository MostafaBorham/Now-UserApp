import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class FilterHeaderView extends StatelessWidget {
  const FilterHeaderView({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: AppBorderRadius.brCircular2,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LangKeys.moreFiltersKey.tr(),
              style: AppTextStyles.style20SemiBold.copyWith(
                color: colors.onTertiaryFixed,
              ),
            ),
            InkWell(
              onTap: onClose,
              child: Icon(
                Icons.close,
                size: 20,
                color: colors.onTertiaryFixed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
