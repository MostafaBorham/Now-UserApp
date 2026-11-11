import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_features_options_view/widgets/product_features_sections/widgets/product_features_section_card/widgets/product_features_section_header.dart';

class ProductFeaturesSectionCard extends StatelessWidget {
  const ProductFeaturesSectionCard({
    super.key,
    required this.title,
    required this.isCollapsed,
    required this.child,
    this.onToggle,
  });

  final String title;
  final bool isCollapsed;
  final Widget child;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: AppBorderRadius.brCircular16,
        border: Border.all(color: colors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductFeaturesSectionHeader(
            title: title,
            isCollapsed: isCollapsed,
            onTap: onToggle,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: AlignmentDirectional.topStart,
            child: isCollapsed
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: child,
                  ),
          ),
        ],
      ),
    );
  }
}
