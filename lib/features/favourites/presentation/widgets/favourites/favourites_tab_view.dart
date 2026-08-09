import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_sort_option.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/favourites/data/models/favourite_category_model.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/favourites/favourite_sort_sheet.dart';
import 'package:nowdelivery_user_app/features/favourites/viewmodel/favourite_categories_vm.dart';

/// The chrome shared by both favourites tabs: an in-place search field, the
/// category chip row and the sort sheet, with the paginated list ([child])
/// below. It owns the filter state and reports every change through
/// [onFiltersChanged]; the concrete tab wires that to its view-model's
/// `applyFilters`. Kept type-agnostic so it serves products and stores alike.
class FavouritesTabView extends ConsumerStatefulWidget {
  const FavouritesTabView({
    super.key,
    required this.type,
    required this.searchHintKey,
    required this.onFiltersChanged,
    required this.child,
  });

  /// API discriminator of the tab — `product` / `vendor`. Scopes the chip row.
  final String type;
  final String searchHintKey;

  /// Called whenever search / category / sort changes. Empty `categoryIds`
  /// means the "All" chip; `sort` is a [FavouriteSortOption] query value.
  final void Function(String? search, List<int> categoryIds, String? sort)
      onFiltersChanged;

  /// The paginated list for this tab.
  final Widget child;

  @override
  ConsumerState<FavouritesTabView> createState() => _FavouritesTabViewState();
}

class _FavouritesTabViewState extends ConsumerState<FavouritesTabView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  /// null → the "All" chip (no category filter).
  int? _selectedCategoryId;
  FavouriteSortOption _sort = FavouriteSortOption.defaultOption;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Hands the current filters to the tab's view-model.
  void _emit() {
    final String search = _searchController.text.trim();
    widget.onFiltersChanged(
      search.isEmpty ? null : search,
      _selectedCategoryId == null ? const <int>[] : <int>[_selectedCategoryId!],
      _sort.queryValue,
    );
  }

  /// Debounced so a burst of keystrokes fires a single request.
  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _emit);
  }

  void _onCategorySelected(int? categoryId) {
    if (categoryId == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    _emit();
  }

  Future<void> _openSortSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => FavouriteSortSheet(
        initial: _sort,
        onApply: (FavouriteSortOption option) {
          if (option == _sort) return;
          setState(() => _sort = option);
          _emit();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: <Widget>[
        AppSearchField(
          hintText: widget.searchHintKey.tr(),
          controller: _searchController,
          navigateToSearchOnTap: false,
          hasFilter: true,
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _emit(),
          onFilterTap: _openSortSheet,
        ),
        _CategoryChipsRow(
          type: widget.type,
          selectedId: _selectedCategoryId,
          onSelected: _onCategorySelected,
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Horizontal "All + categories" chip row driven by [favouriteCategoriesProvider].
/// Collapses to nothing while loading, on error, or when the caller has no
/// categorised favourites — the list still works without it.
class _CategoryChipsRow extends ConsumerWidget {
  const _CategoryChipsRow({
    required this.type,
    required this.selectedId,
    required this.onSelected,
  });

  final String type;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FavouriteCategoryModel> categories = ref
        .watch(favouriteCategoriesProvider(type))
        .valueOrNull ??
        const <FavouriteCategoryModel>[];

    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _Chip(
              label: LangKeys.allKey.tr(),
              selected: selectedId == null,
              onTap: () => onSelected(null),
            );
          }

          final FavouriteCategoryModel category = categories[index - 1];
          return _Chip(
            label: '${context.getLocalizedApiText(category.name)}'
                ' (${category.favoritablesCount})',
            selected: selectedId == category.id,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: AppBorderRadius.brCircular20,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.primaryFixed,
          borderRadius: AppBorderRadius.brCircular20,
        ),
        child: Text(
          label,
          style: AppTextStyles.style14Medium.copyWith(
            color: selected ? colors.onPrimary : colors.onSecondary,
          ),
        ),
      ),
    );
  }
}
