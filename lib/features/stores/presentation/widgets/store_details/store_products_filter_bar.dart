import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class StoreProductsFilterBar extends StatefulWidget {
  const StoreProductsFilterBar({super.key});

  @override
  State<StoreProductsFilterBar> createState() => _StoreProductsFilterBarState();
}

class _StoreProductsFilterBarState extends State<StoreProductsFilterBar> {
  int _selected = 0;

  late final List<String> _filters = [
    LangKeys.allKey.tr(),
    LangKeys.offersKey.tr(),
    'Top Rated',
    LangKeys.mostRequestedKey.tr(),
    'Clothes',
  ];

  static const List<String> _breadcrumb = [
    'Meat',
    'Drink',
    'Vegetables',
    'Dairy Products',
    'Fruits',
    'Snacks',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 12,
            children: List.generate(_filters.length, (index) {
              final bool isSelected = _selected == index;
              return InkWell(
                borderRadius: AppBorderRadius.brCircular20,
                onTap: () => setState(() => _selected = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.brCircular20,
                    color: isSelected ? colors.primary : colors.primaryFixed,
                  ),
                  child: Text(
                    _filters[index],
                    style: AppTextStyles.style16Medium.copyWith(
                      color: isSelected ? colors.onPrimary : colors.onSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_breadcrumb.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(radius: 2, backgroundColor: colors.onSurface),
                );
              }
              return Text(
                _breadcrumb[index ~/ 2],
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.onSurface,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
