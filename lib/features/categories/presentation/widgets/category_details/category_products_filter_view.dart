import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_categories_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_header_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_price_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_ratings_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_separate_options_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_types_view.dart';

class CategoryProductsFilterView extends StatefulWidget {
  const CategoryProductsFilterView({
    super.key,
    required this.ratings,
    this.minPrice = 0,
    this.maxPrice = 10000,
    this.onApply,
    this.onClose,
  });

  final List<String> ratings;
  final double minPrice;
  final double maxPrice;
  final void Function(
      String separateOptionQueryValue,
      double minPrice,
      double maxPrice,
      int ratingIndex,
      )?
  onApply;
  final VoidCallback? onClose;

  @override
  State<CategoryProductsFilterView> createState() => _CategoryProductsFilterViewState();
}

class _CategoryProductsFilterViewState extends State<CategoryProductsFilterView> {
  SeparateOption selectedSeparateOption = SeparateOption.topRated;
  int selectedRatingIndex = 0;
  late RangeValues priceRange = RangeValues(widget.minPrice, widget.maxPrice);
  late final TextEditingController maxLimitController = TextEditingController(
    text: widget.maxPrice.round().toString(),
  );
  late final TextEditingController minLimitController = TextEditingController(
    text: widget.minPrice.round().toString(),
  );

  @override
  void dispose() {
    maxLimitController.dispose();
    minLimitController.dispose();
    super.dispose();
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
        )
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            FilterHeaderView(onClose: widget.onClose ?? () => context.pop()),
            FilterSeparateOptionsView(
              selected: selectedSeparateOption,
              onChanged: (option) =>
                  setState(() => selectedSeparateOption = option),
            ),
            FilterPriceView(
              priceRange: priceRange,
              minPrice: widget.minPrice,
              maxPrice: widget.maxPrice,
              maxLimitController: maxLimitController,
              minLimitController: minLimitController,
              onChanged: (values) => setState(() => priceRange = values),
            ),
            FilterRatingsView(
              ratings: widget.ratings,
              selectedIndex: selectedRatingIndex,
              onChanged: (index) =>
                  setState(() => selectedRatingIndex = index),
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: PrimaryAppButton(
                    title: LangKeys.applyFiltersKey.tr(),
                    onTap: () {
                      widget.onApply?.call(
                        selectedSeparateOption.queryValue,
                        priceRange.start,
                        priceRange.end,
                        selectedRatingIndex,
                      );
                      context.pop();
                    },
                  ),
                ),
                Expanded(child: UnPrimaryAppButton(title: 'Reset Filter'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
