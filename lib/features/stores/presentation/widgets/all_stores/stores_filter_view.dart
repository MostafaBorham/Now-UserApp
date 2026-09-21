import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_bottom_sheet.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_categories_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_ratings_view.dart';

class StoresFilterView extends StatefulWidget {
  const StoresFilterView({
    super.key,
    this.onApply,
    this.initialCategoryIndex = 0,
    this.initialRating,
  });

  /// [categoryIndex] is the selected chip index over the `[All, ...categories]`
  /// list (0 = All), matching the tab order in [AllStoresScreen].
  final void Function(String? rating, int? categoryIndex)? onApply;

  /// The category chip highlighted on open, over `[All, ...categories]`
  /// (0 = All), so the sheet reflects the currently applied category.
  final int initialCategoryIndex;

  /// The rating currently applied (e.g. `'4.5'`), or `null` for none, so the
  /// sheet reflects it on open.
  final String? initialRating;

  @override
  State<StoresFilterView> createState() => _StoresFilterViewState();
}

class _StoresFilterViewState extends State<StoresFilterView> {
  late String? selectedRating = widget.initialRating;

  /// Starts on the currently applied category (defaults to 0 = "All") so apply
  /// always reports the highlighted category — even when the user leaves it.
  late int selectedCategoryIndex = widget.initialCategoryIndex;
  int filtersKey = 0;

  void resetFilters() {
    setState(() {
      selectedRating = null;
      selectedCategoryIndex = 0;
      filtersKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final int ratingIndex = selectedRating == null
        ? -1
        : FilterRatingsView.ratings.indexOf(selectedRating!);
    return FilterBottomSheet(
      onApply: () =>
          widget.onApply?.call(selectedRating, selectedCategoryIndex),
      onReset: resetFilters,
      filters: [
        FilterCategoriesView(
          key: ValueKey('categories_$filtersKey'),
          initialIndex: selectedCategoryIndex,
          selectedLabelColor: colors.white,
          selectedColor: colors.primary500Main,
          onChanged: (index) => selectedCategoryIndex = index,
        ),
        FilterRatingsView(
          key: ValueKey('ratings_$filtersKey'),
          initialIndex: ratingIndex < 0 ? null : ratingIndex,
          onChanged: (rating) => selectedRating = rating,
        ),
      ],
    );
  }
}
