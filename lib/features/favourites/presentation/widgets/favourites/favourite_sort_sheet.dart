import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/favourite_sort_option.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_header_view.dart';

/// Sort sheet for the favourites list — the four orders the endpoint
/// understands, single-select. Commits the pick through [onApply] before it
/// pops itself, mirroring the shared FilterBottomSheet chrome.
class FavouriteSortSheet extends StatefulWidget {
  const FavouriteSortSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  final FavouriteSortOption initial;
  final ValueChanged<FavouriteSortOption> onApply;

  @override
  State<FavouriteSortSheet> createState() => _FavouriteSortSheetState();
}

class _FavouriteSortSheetState extends State<FavouriteSortSheet> {
  late FavouriteSortOption _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: <Widget>[
            FilterHeaderView(onClose: Navigator.of(context).pop),
            Text(
              LangKeys.sortOptionsKey.tr(),
              style: AppTextStyles.style16Medium.copyWith(
                color: colors.onTertiaryFixed,
              ),
            ),
            ...FavouriteSortOption.values.map(
              (FavouriteSortOption option) => _SortOptionTile(
                label: option.label,
                selected: option == _selected,
                onTap: () => setState(() => _selected = option),
              ),
            ),
            Row(
              spacing: 16,
              children: <Widget>[
                Expanded(
                  child: PrimaryAppButton(
                    title: LangKeys.applyFiltersKey.tr(),
                    onTap: () {
                      widget.onApply(_selected);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: UnPrimaryAppButton(
                    title: LangKeys.resetFilterKey.tr(),
                    onTap: () => setState(
                      () => _selected = FavouriteSortOption.defaultOption,
                    ),
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

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
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
      borderRadius: AppBorderRadius.brCircular30,
      onTap: onTap,
      child: Row(
        spacing: 8,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? colors.secondaryFixed : Colors.transparent,
              shape: BoxShape.circle,
              border: selected ? null : Border.all(color: colors.inversePrimary),
            ),
            child: selected
                ? FittedBox(
                    child: Icon(Icons.check_outlined, color: colors.onPrimary),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.style14Regular.copyWith(
                color: colors.onTertiaryFixed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
