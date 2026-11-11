import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/reviews_sort_option.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_sections_sheet/filter_sections_sheet.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_reviews/reviews_filter_view/widgets/reviews_sort_section.dart';

class ReviewsFilterView extends StatefulWidget {
  const ReviewsFilterView({super.key, this.initialSortOption, this.onApply});

  final ReviewsSortOption? initialSortOption;
  final ValueChanged<ReviewsSortOption?>? onApply;

  static Future<void> show(
    BuildContext context, {
    ReviewsSortOption? initialSortOption,
    ValueChanged<ReviewsSortOption?>? onApply,
  }) {
    return FilterSectionsSheet.show(
      context,
      builder: (_) => ReviewsFilterView(
        initialSortOption: initialSortOption,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ReviewsFilterView> createState() => _ReviewsFilterViewState();
}

class _ReviewsFilterViewState extends State<ReviewsFilterView> {
  late ReviewsSortOption? _sortOption = widget.initialSortOption;

  @override
  Widget build(BuildContext context) {
    return FilterSectionsSheet(
      titles: [LangKeys.sortByKey.tr()],
      onApply: () => widget.onApply?.call(_sortOption),
      onReset: () => setState(() => _sortOption = null),
      sectionBuilder: (_) => ReviewsSortSection(
        selectedOption: _sortOption,
        onChanged: (option) => setState(() => _sortOption = option),
      ),
    );
  }
}
