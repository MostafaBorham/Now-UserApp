import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_banner_section_view.dart';

/// The `special offers` section: the admin-curated auto-scrolling offers
/// carousel and the header banner carousel stacked over the shared
/// [Assets.media.images.svg.homeOffersBackground] starburst, which stretches to
/// the full height of their column.
class HomeSpecialOffersSectionView extends StatelessWidget {
  const HomeSpecialOffersSectionView({
    super.key,
    this.title,
    this.offers = const <HomeOfferModel>[],
    this.showTopBanner = false,
  });

  /// Section title as the feed's `{ar, en}` map; falls back to a generic
  /// "Special offers" label when the admin left it empty.
  final Map<String, dynamic>? title;
  final List<HomeOfferModel> offers;
  final bool showTopBanner;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty && !showTopBanner) return const SizedBox.shrink();

    final AppColorScheme colors = context.colors;
    final String localizedTitle = context.getLocalizedApiText(title);
    final String heading = localizedTitle.isNotEmpty
        ? localizedTitle
        : LangKeys.specialOffersKey.tr();

    return LayoutBuilder(
      builder: (context, con) {
        final double offerCardHeight = con.maxWidth * 0.4;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 10.0),
              child: Text(
                heading,
                style: TextStyle(
                  fontSize: con.maxWidth * 0.05,
                  color: colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Stack(
              children: [
                Positioned(
                  top: offerCardHeight * 2 / 3,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Assets.media.images.svg.homeOffersBackground.svg(
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 20,
                    children: [
                      if (offers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 10.0,
                          ),
                          child: SizedBox(
                            height:
                                offerCardHeight +
                                _AutoScrollOffersList.shadowInset * 2,
                            child: _AutoScrollOffersList(offers: offers),
                          ),
                        ),
                      if (showTopBanner) const HomeTopBannerSectionView(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Routes an offer tap by its `kind`. `store` opens store details by id;
/// `product` and `category` open their details screen by slug. Any other
/// kind — or a missing target — is inert.
void _onOfferTap(BuildContext context, HomeOfferModel offer) {
  switch (offer.kind) {
    case 'store':
      if (offer.storeId != null) {
        context.pushNamed(
          AppRoutes.storeDetailsScreen,
          pathParameters: <String, String>{'id': '${offer.storeId}'},
        );
      }
      break;
    case 'product':
      final String? slug = offer.productSlug;
      if (slug != null && slug.isNotEmpty) {
        context.pushNamed(AppRoutes.productDetailsScreen, extra: slug);
      }
      break;
    case 'category':
      // The link carries only the slug, which is all category details needs to
      // load itself (same as a banner's category tap).
      final String? categorySlug = offer.categorySlug;
      if (categorySlug != null && categorySlug.isNotEmpty) {
        context.pushNamed(
          AppRoutes.categoryDetailsScreen,
          pathParameters: <String, String>{'slug': categorySlug},
        );
      }
      break;
  }
}

class _AutoScrollOffersList extends StatefulWidget {
  const _AutoScrollOffersList({required this.offers});

  /// Room above and below the cards for their shadow, which the list would
  /// otherwise clip.
  static const double shadowInset = 4;

  final List<HomeOfferModel> offers;

  @override
  State<_AutoScrollOffersList> createState() => _AutoScrollOffersListState();
}

class _AutoScrollOffersListState extends State<_AutoScrollOffersList> {
  static const Duration _dwell = Duration(seconds: 3);
  static const Duration _step = Duration(milliseconds: 900);
  static const double _separator = 12;
  static const double _aspectRatio = 0.7;

  final ScrollController _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer.periodic(_dwell, (_) => _stepForward());
    });
  }

  void _stepForward() {
    if (!_controller.hasClients) return;
    final ScrollPosition position = _controller.position;
    final double max = position.maxScrollExtent;
    if (max <= 0) return;

    // Advance by exactly one card so each step hides the current first
    // visible item. The card width is derived from the list's height
    // (its cross-axis extent) and the card's aspect ratio.
    final double listHeight = context.size?.height ?? 0;
    if (listHeight <= 0) return;
    final double itemExtent =
        (listHeight - _AutoScrollOffersList.shadowInset * 2) * _aspectRatio +
        _separator;

    final double target = position.pixels >= max - 1.0
        ? 0.0
        : (position.pixels + itemExtent).clamp(0.0, max);

    _controller.animateTo(target, duration: _step, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsetsDirectional.only(
        end: 10,
        top: _AutoScrollOffersList.shadowInset,
        bottom: _AutoScrollOffersList.shadowInset,
      ),
      scrollDirection: Axis.horizontal,
      // Scroll right-to-left in Arabic, left-to-right in English — see the
      // motion rule on `AppSlider`. This mirrors the card order (the first
      // offer sits on the leading edge of the sweep, still the first one
      // seen), which is what keeps the drift going the same way as the
      // carousels above it.
      reverse: true,
      itemBuilder: (context, index) {
        final HomeOfferModel offer = widget.offers[index];
        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onOfferTap(context, offer),
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              // The top banner's own shadow, so the two strips match. Each
              // card is its own RepaintBoundary, so this is painted once and
              // only moved while the strip steps.
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AppCachedNetworkImage(
                    imageUrl: offer.imageUrl ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemCount: widget.offers.length,
    );
  }
}
