import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Pale gradient wrapper shared by the Track Order sections
/// ("Item Information", "Delivery Details"): a soft cream→green card with a
/// [title] header and one white inner surface per entry of [children], so
/// each entry (e.g. each ordered product) reads as its own card.
///
/// Mirrors the card style already used on the Order Details screen so the
/// tracking flow reads as part of the same family.
class TrackingSectionCard extends StatelessWidget {
  const TrackingSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            colors.secondary100,
            colors.primary100.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: AppBorderRadius.brCircular12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            title,
            style: AppTextStyles.style16SemiBold.copyWith(color: colors.black),
          ),
          for (final Widget child in children)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: AppBorderRadius.brCircular8,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}
