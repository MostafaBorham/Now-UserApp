import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_bottom_sheet.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_ratings_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_types_view.dart';

class CategoryStoresFilterView extends StatefulWidget {
  const CategoryStoresFilterView({super.key, this.onApply});

  final void Function(
    StoresSortType? type,
    String? rating,
  )?
  onApply;

  @override
  State<CategoryStoresFilterView> createState() =>
      _CategoryStoresFilterViewState();
}

class _CategoryStoresFilterViewState extends State<CategoryStoresFilterView> {
  StoresSortType? selectedType;
  String? selectedRating;
  int filtersKey = 0;

  void resetFilters() {
    setState(() {
      selectedType = null;
      selectedRating = null;
      filtersKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheet(
      onApply: () => widget.onApply?.call(selectedType, selectedRating),
      onReset: resetFilters,
      filters: [
        FilterTypesView(
          key: ValueKey('types_$filtersKey'),
          onChanged: (type) => selectedType = type,
        ),
        FilterRatingsView(
          key: ValueKey('ratings_$filtersKey'),
          onChanged: (rating) => selectedRating = rating,
        ),
      ],
    );
  }
}