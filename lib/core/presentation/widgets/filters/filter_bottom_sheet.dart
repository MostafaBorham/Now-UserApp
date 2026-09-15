import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/filters/filter_header_view.dart';







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
