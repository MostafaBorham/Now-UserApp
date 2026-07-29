import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class FilterTypesView extends StatelessWidget {
  const FilterTypesView({super.key, this.onChanged});

  final ValueChanged<StoresSortType>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          LangKeys.storeTypeKey.tr(),
          style: AppTextStyles.style16Medium.copyWith(
            color: colors.onTertiaryFixed,
          ),
        ),
        AppSelector(
          items: StoresSortType.values.map((type) => type.label.tr()).toList(),
          initialIndex: null,
          onChanged: (index) => onChanged?.call(StoresSortType.values[index]),
          labelColor: colors.onSecondary,
          selectedColor: colors.tertiaryContainer,
          radius: 999,
          borderColor: Colors.transparent,
          unselectedColor: colors.onSurface.withValues(alpha: 0.1),
        )
      ],
    );
  }
}
