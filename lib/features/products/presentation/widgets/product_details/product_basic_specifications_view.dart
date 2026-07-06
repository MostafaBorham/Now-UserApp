import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ProductBasicSpecificationsView extends StatelessWidget {
  const ProductBasicSpecificationsView({
    super.key,
    this.specifications = const {
      'Processor': 'Apple M3 Chip',
      'RAM': '16 GB',
      'Storage': '512 GB SSD',
      'Display': '13.6" Liquid Retina',
      'Battery': 'Up to 18 hours',
      'Weight': '1.24 kg',
    },
  });

  final Map<String, String> specifications;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final List<MapEntry<String, String>> entries =
        specifications.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          'Basic Specifications',
          style: AppTextStyles.style16Bold.copyWith(
            color: colors.onSecondary,
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.onPrimaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.surfaceContainerLow),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < entries.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: i == entries.length - 1
                        ? null
                        : Border(
                            bottom: BorderSide(color: colors.surfaceContainerLow),
                          ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        entries[i].key,
                        style: AppTextStyles.style14Regular.copyWith(
                          color: colors.onSurface,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entries[i].value,
                          textAlign: TextAlign.end,
                          style: AppTextStyles.style14SemiBold.copyWith(
                            color: colors.onSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
