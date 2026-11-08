import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class Search2RecentSearchSection extends StatefulWidget {
  const Search2RecentSearchSection({super.key});

  @override
  State<Search2RecentSearchSection> createState() =>
      _Search2RecentSearchSectionState();
}

class _Search2RecentSearchSectionState
    extends State<Search2RecentSearchSection> {
  bool _isEditing = false;

  final List<({String name, String imageUrl})>
  _products = <({String name, String imageUrl})>[
    (
      name: 'Milk',
      imageUrl: 'https://pngimg.com/uploads/milk/milk_PNG12737.png',
    ),
    (
      name: 'Vegetables',
      imageUrl:
          'https://static.vecteezy.com/system/resources/previews/054/125/772/non_2x/shopping-cart-full-of-vegetable-on-transparent-background-png.png',
    ),
    (
      name: 'Meat',
      imageUrl: 'https://pngimg.com/uploads/steak/steak_PNG15.png',
    ),
    (
      name: 'Milk',
      imageUrl: 'https://pngimg.com/uploads/milk/milk_PNG12737.png',
    ),
    (
      name: 'Fish',
      imageUrl: 'https://pngimg.com/uploads/fish/fish_PNG25137.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_products.isEmpty) return const SizedBox.shrink();
    final AppColorScheme colors = context.colors;

    return LayoutBuilder(
      builder: (context, con) {
        final double cardSize = con.maxWidth * 0.185;
        final double badgeSize = cardSize * 0.22;
        final double badgeOverflow = badgeSize * 0.4;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16 - badgeOverflow,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      LangKeys.lastThingYouSearchedForKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.style16Bold.copyWith(
                        color: colors.tertiaryContainer,
                        fontSize: con.maxWidth * 0.041,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _isEditing = !_isEditing),
                    child: Text(
                      (_isEditing ? LangKeys.doneKey : LangKeys.editKey).tr(),
                      style: AppTextStyles.style12Medium.copyWith(
                        color: colors.tertiaryContainer,
                        fontSize: con.maxWidth * 0.031,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: cardSize * 0.11 - badgeOverflow,
                children: [
                  for (final (
                        int index,
                        ({String name, String imageUrl}) product,
                      )
                      in _products.indexed)
                    Stack(
                      children: [
                        Container(
                          width: cardSize,
                          margin: EdgeInsetsDirectional.only(
                            top: badgeOverflow,
                            end: badgeOverflow,
                          ),
                          child: Column(
                            spacing: 8,
                            children: [
                              Container(
                                width: cardSize,
                                height: cardSize,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: colors.neutral1200.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    cardSize * 0.15,
                                  ),
                                ),
                                child: AppCachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  width: cardSize,
                                  height: cardSize,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.style12SemiBold.copyWith(
                                  color: colors.tertiaryContainer,
                                  fontSize: cardSize * 0.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isEditing)
                          PositionedDirectional(
                            top: 0,
                            end: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  setState(() => _products.removeAt(index)),
                              child: Container(
                                width: badgeSize,
                                height: badgeSize,
                                decoration: BoxDecoration(
                                  color: colors.red300Main,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: badgeSize * 0.7,
                                  color: colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
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
