import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';

/// The `featured_offers` section: an auto-scrolling carousel of admin-curated
/// offers. Each card shows the offer image and, on tap, navigates by its `kind`
/// (see [_onOfferTap]).
class HomeOffersSectionView extends StatelessWidget {
  const HomeOffersSectionView({super.key, this.title, required this.offers});

  /// Section title, already localized by the feed; falls back to a generic
  /// "Special offers" label when the admin left it empty.
  final String? title;
  final List<HomeOfferModel> offers;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    final AppColorScheme colors = context.colors;
    final String heading =
        (title != null && title!.isNotEmpty) ? title! : LangKeys.specialOffersKey.tr();

    return LayoutBuilder(
      builder: (context, con) {
        return SizedBox(
          width: con.maxWidth,
          child: Stack(
            children: [
              Positioned(
                bottom: 12,
                height: con.maxWidth * 0.6,
                width: con.maxWidth,
                child: Assets.media.images.svg.homeOffersBackground.svg(
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        fontSize: con.maxWidth * 0.05,
                        color: colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: con.maxWidth * 0.4,
                      child: _AutoScrollOffersList(offers: offers),
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

/// Routes an offer tap by its `kind`. `store` opens store details by id;
/// `product` opens product details by slug. Any other kind — or a missing
/// target — is inert.
void _onOfferTap(BuildContext context, HomeOfferModel offer) {
  switch (offer.kind) {
    case 'store':
      if (offer.storeId != null) {
        context.pushNamed(AppRoutes.storeDetailsScreen, extra: offer.storeId);
      }
      break;
    case 'product':
      // ponytail: inert until the backend emits a product slug in link (the
      // stored target is a product id today, and product details is slug-only).
      final String? slug = offer.productSlug;
      if (slug != null && slug.isNotEmpty) {
        context.pushNamed(AppRoutes.productDetailsScreen, extra: slug);
      }
      break;
  }
}

class _AutoScrollOffersList extends StatefulWidget {
  const _AutoScrollOffersList({required this.offers});

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
    final double itemExtent = listHeight * _aspectRatio + _separator;

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
    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsetsDirectional.only(end: 10),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final HomeOfferModel offer = widget.offers[index];
        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onOfferTap(context, offer),
            child: AspectRatio(
              aspectRatio: _aspectRatio,
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
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemCount: widget.offers.length,
    );
  }
}
