import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/enums/stores_sort_type.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_header_view.dart';
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
            FilterTypesView(
              key: ValueKey('types_$filtersKey'),
              onChanged: (type) => selectedType = type,
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
                        selectedType,
                        selectedRating,
                      );
                      context.pop();
                    },
                  ),
                ),
                Expanded(
                  child: UnPrimaryAppButton(
                    title: LangKeys.resetFilterKey.tr(),
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
