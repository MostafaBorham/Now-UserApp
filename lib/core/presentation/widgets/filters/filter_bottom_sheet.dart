import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_header_view.dart';

/// The shared chrome for a filter bottom sheet: rounded top container, close
/// header, the caller's [filters] controls, then Apply / Reset buttons.
///
/// Each screen keeps its own filter state and supplies the middle [filters];
/// this widget owns only the layout, the header, and the two actions. The sheet
/// closes itself after Apply.
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
    required this.filters,
    this.onApply,
    this.onReset,
  });

  final List<Widget> filters;

  final VoidCallback? onApply;

  final VoidCallback? onReset;

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
          children: [
            FilterHeaderView(onClose: () => context.pop()),
            ...filters,
            Row(
              spacing: 16,
              children: [
                if (onApply != null)
                  Expanded(
                    child: PrimaryAppButton(
                      title: LangKeys.applyFiltersKey.tr(),
                      titleStyle: AppTextStyles.style16Medium,
                      onTap: () {
                        onApply?.call();
                        context.pop();
                      },
                    ),
                  ),
                if (onReset != null)
                  Expanded(
                    child: UnPrimaryAppButton(
                      title: LangKeys.resetFilterKey.tr(),
                      titleStyle: AppTextStyles.style16Medium,
                      onTap: onReset,
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
