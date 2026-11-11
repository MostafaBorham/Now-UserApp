import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class FilterSectionCard extends StatelessWidget {
  const FilterSectionCard({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.child,
    this.onToggle,
  });

  static const Duration _toggleDuration = Duration(milliseconds: 250);

  final String title;
  final bool isExpanded;
  final Widget child;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Material(
      color: colors.primaryFixed,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.brCircular16,
        side: BorderSide(color: colors.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: AppBorderRadius.brCircular8,
              onTap: onToggle,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.style14Bold.copyWith(
                        color: colors.neutral1200,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0 : 0.5,
                    duration: _toggleDuration,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 12,
                      color: colors.onPrimaryFixed,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: _toggleDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: child,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
