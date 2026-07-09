import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// Pale gradient wrapper shared by the Track Order sections
/// ("Item Information", "Delivery Details"): a soft cream→green card with a
/// [title] header and a white inner surface that hosts [child].
///
/// Mirrors the card style already used on the Order Details screen so the
/// tracking flow reads as part of the same family.
class TrackingSectionCard extends StatelessWidget {
  const TrackingSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            colors.onTertiaryFixedVariant,
            colors.onSurfaceVariant.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: AppBorderRadius.brCircular12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.style16SemiBold.copyWith(
              color: colors.onSecondary,
            ),
          ),
          12.hSpace,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.onPrimary,
              borderRadius: AppBorderRadius.brCircular8,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
