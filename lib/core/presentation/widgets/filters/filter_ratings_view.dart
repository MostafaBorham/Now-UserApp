import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_rate_selector.dart';

class FilterRatingsView extends StatelessWidget {
  const FilterRatingsView({
    super.key,
    required this.ratings,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> ratings;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          LangKeys.ratingsKey.tr(),
          style: AppTextStyles.style14SemiBold.copyWith(
            color: colors.tertiaryContainer,
          ),
        ),
        AppRateSelector(
          ratings: ratings,
          initialIndex: selectedIndex,
          onChanged: onChanged,
          labelColor: colors.onSecondary,
          starColor: colors.surface,
          selectedColor: colors.tertiaryFixed,
          unselectedColor: colors.onPrimaryContainer,
        ),
      ],
    );
  }
}
