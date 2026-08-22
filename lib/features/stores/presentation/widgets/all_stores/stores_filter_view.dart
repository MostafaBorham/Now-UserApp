import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_bottom_sheet.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_categories_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_ratings_view.dart';

class StoresFilterView extends StatefulWidget {
  const StoresFilterView({super.key, this.onApply});

  /// [categoryIndex] is the selected chip index over the `[All, ...categories]`
  /// list (0 = All), matching the tab order in [AllStoresScreen].
  final void Function(
    StoresSortType? type,
    String? rating,
    int? categoryIndex,
  )?
  onApply;

  @override
  State<StoresFilterView> createState() => _StoresFilterViewState();
}

class _StoresFilterViewState extends State<StoresFilterView> {
  StoresSortType? selectedType;
  String? selectedRating;

  /// Defaults to 0 (the "All" chip that [AppSelector] pre-selects) so apply always
  /// reports the highlighted category — even when the user leaves it on All.
  int selectedCategoryIndex = 0;
  int filtersKey = 0;

  void resetFilters() {
    setState(() {
      selectedType = null;
      selectedRating = null;
      selectedCategoryIndex = 0;
      filtersKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return FilterBottomSheet(
      onApply: () => widget.onApply?.call(
        selectedType,
        selectedRating,
        selectedCategoryIndex,
      ),
      // onReset: resetFilters,
      filters: [
        FilterCategoriesView(
          key: ValueKey('categories_$filtersKey'),
          selectedLabelColor: colors.white,
          selectedColor: colors.primary500Main,
          onChanged: (index) => selectedCategoryIndex = index,
        ),
        FilterRatingsView(
          key: ValueKey('ratings_$filtersKey'),
          onChanged: (rating) => selectedRating = rating,
        ),
      ],
    );
  }
}
