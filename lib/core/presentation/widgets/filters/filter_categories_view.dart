import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

class FilterCategoriesView extends ConsumerWidget {
  const FilterCategoriesView({
    super.key,
    this.onChanged,
    this.selectedColor,
    this.selectedLabelColor,
  });

  final ValueChanged<int>? onChanged;
  final Color? selectedColor;
  final Color? selectedLabelColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final AsyncValue<PaginationModel<CategoryModel>> state =
        ref.watch(getAppCategoriesProvider);
    final bool isLoading = state.isLoading && !state.hasValue;

    final List<String> items = [LangKeys.allKey.tr()];
    state.whenData((page) {
      items.addAll(page.data.map((c) => context.getLocalizedApiText(c.name)));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          LangKeys.categoriesKey.tr(),
          style: AppTextStyles.style16Medium.copyWith(
            color: colors.neutral1200,
          ),
        ),
        if (isLoading)
          SizedBox(
            height: 36,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 12,
                children: [
                  SelectorItem(
                    label: LangKeys.allKey.tr(),
                    isSelected: true,
                    radius: 999,
                    borderColor: Colors.transparent,
                    selectedColor: selectedColor ?? colors.primary500Main,
                    selectedLabelColor: selectedLabelColor ?? colors.white,
                    unselectedColor: colors.neutral500.withValues(alpha: 0.1),
                  ),
                  ...List.generate(
                    4,
                    (_) => AppShimmer(
                      child: Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.neutral500.withValues(alpha: 0.1),
                          borderRadius: AppBorderRadius.brCircular30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          AppSelector(
            items: items,
            initialIndex: 0,
            onChanged: onChanged,
            labelColor: colors.black,
            selectedColor: selectedColor ?? colors.surfaceContainerHigh,
            radius: 999,
            selectedLabelColor: selectedLabelColor ?? colors.black,
            borderColor: Colors.transparent,
            unselectedColor: colors.neutral500.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}
