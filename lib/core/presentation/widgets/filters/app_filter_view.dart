import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_rate_selector.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';
import 'package:nowdelivery_user_app/features/categories/viewmodel/get_app_categories_vm.dart';

class AppFilterView extends ConsumerStatefulWidget {
  const AppFilterView({
    super.key,
    required this.categories,
    required this.ratings,
    this.onApply,
    this.onClose,
  });

  final List<String> categories;
  final List<String> ratings;
  final void Function(int categoryIndex, int ratingIndex)? onApply;
  final VoidCallback? onClose;

  @override
  ConsumerState<AppFilterView> createState() => _AppFilterViewState();
}

class _AppFilterViewState extends ConsumerState<AppFilterView> {
  int selectedCategoryIndex = 0;
  int selectedRatingIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final categoriesState = ref.watch(getAppCategoriesProvider);
    return Container(
      color: colors.onPrimary,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: AppBorderRadius.brCircular2,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LangKeys.moreFiltersKey.tr(),
                style: AppTextStyles.style20SemiBold.copyWith(
                  color: colors.onTertiaryFixed,
                ),
              ),
              InkWell(
                onTap: widget.onClose ?? () => context.pop(),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: colors.onTertiaryFixed,
                ),
              ),
            ],
          ),
          Text(
            LangKeys.categoriesKey.tr(),
            style: AppTextStyles.style14SemiBold.copyWith(
              color: colors.onTertiaryFixed,
            ),
          ),
          categoriesState.when(
            loading: () => Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: AppShimmer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            error: (error, stackTrace) => ServerConnectionErrorWidget(
              message: error.toString(),
              onRetry: () => ref
                  .read(getAppCategoriesProvider.notifier)
                  .getAppCategories(),
            ),
            data: (categories) => AppSelector(
              items: categories.map((category) => category.name??'',).toList(),
              initialIndex: selectedCategoryIndex,
              onChanged: (index) => selectedCategoryIndex = index,
              labelColor: colors.onTertiaryFixed,
              radius: 999,
              selectedColor: colors.surfaceContainerHigh,
              selectedLabelColor: colors.onTertiaryFixed,
              unselectedColor: colors.onPrimaryContainer,
              borderColor: Colors.transparent,
            ),
          ),
          Text(
            LangKeys.ratingsKey.tr(),
            style: AppTextStyles.style14SemiBold.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          AppRateSelector(
            ratings: widget.ratings,
            initialIndex: selectedRatingIndex,
            onChanged: (index) => selectedRatingIndex = index,
            labelColor: colors.onSecondary,
            starColor: colors.surface,
            selectedColor: colors.tertiaryFixed,
            unselectedColor: colors.onPrimaryContainer,
          ),
          PrimaryAppButton(
            title: LangKeys.applyFiltersKey.tr(),
            onTap: () {
              widget.onApply?.call(selectedCategoryIndex, selectedRatingIndex);
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
