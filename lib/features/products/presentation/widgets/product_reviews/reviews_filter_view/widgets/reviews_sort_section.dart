import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/reviews_sort_option.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_selectable_chip.dart';

class ReviewsSortSection extends StatelessWidget {
  const ReviewsSortSection({super.key, this.selectedOption, this.onChanged});

  final ReviewsSortOption? selectedOption;
  final ValueChanged<ReviewsSortOption?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: ReviewsSortOption.values.map((option) {
        final bool isSelected = option == selectedOption;
        return FilterSelectableChip(
          isSelected: isSelected,
          selectedColor: colors.primary500Main.withValues(alpha: 0.1),
          selectedBorderColor: colors.primary500Main,
          selectedBorderWidth: 1.5,
          borderRadius: AppBorderRadius.brCircular8,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          onTap: () => onChanged?.call(isSelected ? null : option),
          child: Text(
            option.label,
            style: isSelected
                ? AppTextStyles.style14SemiBold.copyWith(
                    color: colors.primary500Main,
                  )
                : AppTextStyles.style14Regular.copyWith(
                    color: colors.onPrimaryFixed,
                  ),
          ),
        );
      }).toList(),
    );
  }
}
