import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class Search2MostSearchedSection extends StatelessWidget {
  const Search2MostSearchedSection({super.key, this.onSelect});

  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return LayoutBuilder(
      builder: (context, con) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                LangKeys.mostSearchedKey.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.style16Bold.copyWith(
                  color: colors.neutral1200,
                  fontSize: con.maxWidth * 0.041,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  for (final String tag in const <String>[
                    'Mobile Phones',
                    'Laptops',
                    'Tablets',
                    'Headphones',
                    'Chargers',
                    'Smartwatches',
                    'Cameras',
                    'Monitors',
                    'Printers',
                    'Home appliances',
                    'Makeup',
                    'Perfumes',
                    'Skincare',
                    'Hair Care',
                    'Accessories',
                    'Shoes',
                    'Clothing',
                    'Bags',
                    'Glasses',
                    'Toys',
                  ])
                    IntrinsicWidth(
                      child: SelectorItem(
                        label: tag,
                        isSelected: false,
                        onTap: () => onSelect?.call(tag),
                        radius: 999,
                        borderColor: colors.primary500Main,
                        unselectedColor: colors.white,
                        labelColor: colors.neutral1200,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
