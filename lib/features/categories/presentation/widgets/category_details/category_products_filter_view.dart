import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/enums/separate_option.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_header_view.dart';
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            FilterHeaderView(onClose: () => context.pop()),
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
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: PrimaryAppButton(
                    title: LangKeys.applyFiltersKey.tr(),
                    onTap: () {
                      widget.onApply?.call(
                        selectedSeparateOption,
                        maxPrice,
                        minPrice,
                        selectedRating,
                      );
                      context.pop();
                    },
                  ),
                ),
                Expanded(
                  child: UnPrimaryAppButton(
                    title: 'Reset Filter',
                    onTap: resetFilters,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
