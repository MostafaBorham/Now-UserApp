import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/separate_option.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_bottom_sheet.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_price_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_ratings_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_separate_options_view.dart';

class CategoryProductsFilterView extends StatefulWidget {
  const CategoryProductsFilterView({super.key, this.onApply});

  final void Function(
    SeparateOption? separateOption,
    double? maxPrice,
    double? minPrice,
    String? rating,
  )?
  onApply;

  @override
  State<CategoryProductsFilterView> createState() =>
      _CategoryProductsFilterViewState();
}

class _CategoryProductsFilterViewState
    extends State<CategoryProductsFilterView> {
  SeparateOption? selectedSeparateOption;
  double? maxPrice;
  double? minPrice;
  String? selectedRating;
  int filtersKey = 0;


  void resetFilters() {
    setState(() {
      selectedSeparateOption = null;
      maxPrice = null;
      minPrice = null;
      selectedRating = null;
      filtersKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheet(
      onApply: () => widget.onApply?.call(
        selectedSeparateOption,
        maxPrice,
        minPrice,
        selectedRating,
      ),
      onReset: resetFilters,
      filters: [
        FilterSeparateOptionsView(
          key: ValueKey('separateOptions_$filtersKey'),
          onChanged: (option) => selectedSeparateOption = option,
        ),
        FilterPriceView(
          key: ValueKey('price_$filtersKey'),
          onChanged: (values) {
            minPrice = values.start;
            maxPrice = values.end;
          },
        ),
        FilterRatingsView(
          key: ValueKey('ratings_$filtersKey'),
          onChanged: (rating) => selectedRating = rating,
        ),
      ],
    );
  }
}
