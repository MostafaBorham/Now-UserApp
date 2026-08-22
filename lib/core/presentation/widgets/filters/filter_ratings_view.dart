import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_rate_selector.dart';

class FilterRatingsView extends StatelessWidget {
  const FilterRatingsView({super.key, this.onChanged});

  static const List<String> ratings = ['4.0', '4.5', '5'];

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
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
          initialIndex: 0,
          onChanged: (index) => onChanged?.call(ratings[index]),
          labelColor: colors.black,
          starColor: colors.surface,
          selectedColor: colors.tertiaryFixed,
          unselectedColor: colors.onPrimaryContainer,
        ),
      ],
    );
  }
}
