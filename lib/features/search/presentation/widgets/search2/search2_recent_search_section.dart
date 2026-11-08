import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/search/data/last_search_results_cache.dart';

class Search2RecentSearchSection extends ConsumerStatefulWidget {
  const Search2RecentSearchSection({
    super.key,
    required this.products,
    required this.stores,
    required this.isLoading,
  });

  final List<LastSearchCard> products;
  final List<LastSearchCard> stores;
  final bool isLoading;

  @override
  ConsumerState<Search2RecentSearchSection> createState() =>
      _Search2RecentSearchSectionState();
}

class _Search2RecentSearchSectionState
    extends ConsumerState<Search2RecentSearchSection> {
  bool _isEditing = false;

  void _openResult(LastSearchCard card, {required bool isProduct}) {
    final String? id = card.routeId;
    if (id == null) return;
    if (isProduct) {
      context.pushNamed(AppRoutes.productDetailsScreen, extra: id);
    } else {
      context.pushNamed(
        AppRoutes.storeDetailsScreen,
        pathParameters: {'id': id},
        extra: {'en': card.en, 'ar': card.ar},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final cards = widget.isLoading
        ? List<LastSearchCard?>.filled(5, null)
        : <LastSearchCard?>[...widget.products, ...widget.stores];

    return LayoutBuilder(
      builder: (context, con) {
        final double cardSize = con.maxWidth * 0.185;
        final double badgeSize = cardSize * 0.22;
        final double badgeOverflow = badgeSize * 0.4;

        return AppShimmer(
          enabled: widget.isLoading,
          child: Column(
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
                    for (final (int index, LastSearchCard? card)
                        in cards.indexed)
                      Stack(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _isEditing || card?.routeId == null
                                ? null
                                : () => _openResult(
                                    card!,
                                    isProduct: index < widget.products.length,
                                  ),
                            child: Container(
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
                                    child: card == null
                                        ? ColoredBox(color: colors.white)
                                        : AppCachedNetworkImage(
                                            imageUrl: card.imageUrl,
                                            width: cardSize,
                                            height: cardSize,
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                  if (card == null)
                                    Container(
                                      width: cardSize * 0.7,
                                      height: cardSize * 0.15,
                                      decoration: BoxDecoration(
                                        color: colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    )
                                  else
                                    Text(
                                      context.getLocalizedApiText({
                                        'en': card.en,
                                        'ar': card.ar,
                                      }),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.style12SemiBold
                                          .copyWith(
                                            color: colors.tertiaryContainer,
                                            fontSize: cardSize * 0.15,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_isEditing && card != null)
                            PositionedDirectional(
                              top: 0,
                              end: 0,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => ref
                                    .read(lastSearchResultsCacheProvider)
                                    .remove(
                                      card,
                                      isProduct: index < widget.products.length,
                                    ),
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
          ),
        );
      },
    );
  }
}
