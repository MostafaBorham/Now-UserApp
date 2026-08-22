import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_bottom_sheet.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_categories_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_ratings_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_types_view.dart';

class StoresFilterView extends StatefulWidget {
  const StoresFilterView({super.key, this.onApply});

  final void Function(
    StoresSortType? type,
    String? rating,
  )?
  onApply;

  @override
  State<StoresFilterView> createState() =>
      _StoresFilterViewState();
}

class _StoresFilterViewState extends State<StoresFilterView> {
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
    final AppColorScheme colors = context.colors;
    return FilterBottomSheet(
      onApply: () => widget.onApply?.call(selectedType, selectedRating),
      // onReset: resetFilters,
      filters: [
        FilterCategoriesView(
          key: ValueKey('categories_$filtersKey'),
          selectedLabelColor: colors.white,
          selectedColor: colors.primary500Main,
          categories: [
            CategoryModel(
              name: {
                'en' : 'All',
                'ar' : 'الكل'
              }
            ),
            CategoryModel(
              id: 0,
                name: {
                  'en' : 'Clothes',
                  'ar' : 'الملابس'
                }
            ),
            CategoryModel(
                id: 1,
                name: {
                  'en' : 'Shoes',
                  'ar' : 'الأحذية'
                }
            ),
            CategoryModel(
                id: 2,
                name: {
                  'en' : 'Electronics',
                  'ar' : 'الالكترونيات'
                }
            ),
          ],
        ),
        FilterRatingsView(
          key: ValueKey('ratings_$filtersKey'),
          onChanged: (rating) => selectedRating = rating,
        ),
      ],
    );
  }
}