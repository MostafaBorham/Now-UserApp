// `easy_localization` re-exports intl's `TextDirection`, which collides with
// the framework's own (used by `_SlideInOnOpen`).
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/data/models/category_model.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_header_banners_vm.dart';

/// The top banner carousel shown under `HomeOffersSectionView`.
///
/// Only mounted when the `/api/v1/home-sections` feed carries a `top_banner`
/// section; its content is a separate fetch of
/// `/api/v1/banners?type=header_main_page`. One banner renders as a static
/// image, many as an auto-playing carousel with dots (both via [AppSlider]).
/// Silent on empty/error — it is decorative, so it just takes no space.
class HomeTopBannerSectionView extends ConsumerWidget {
  const HomeTopBannerSectionView({super.key});

  /// Figma 7137:26468 — the banner is a 355×118 box inset 17.5px from each
  /// screen edge, 18px corners, drop shadow `0 0 4 rgba(0, 0, 0, 0.25)`.
  static const double _bannerAspectRatio = 355 / 118;
  static const double _sideMargin = 17.5;
  static const double _radius = 18;

  /// Padding [AppSlider] puts around every carousel item (its default). It
  /// eats into both the side margin and the item's height, so both are backed
  /// out below to land the banner itself on the design's box.
  static const double _sliderSpace = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BannerModel>> banners = ref.watch(
      getHeaderBannersProvider,
    );

    return banners.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: _sideMargin),
        child: AspectRatio(
          aspectRatio: _bannerAspectRatio,
          child: _BannerSkeleton(),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (List<BannerModel> items) {
        if (items.isEmpty) return const SizedBox.shrink();
        // The decorative starburst (moved here from HomeOffersSectionView)
        // keeps its natural box — full device width, `width * 0.6` tall — and
        // the banner is centered on top of it, so it bleeds above and below.
        return LayoutBuilder(
          builder: (context, con) {
            final double bannerWidth = con.maxWidth - (_sideMargin * 2);
            final double viewportWidth =
                con.maxWidth - ((_sideMargin - _sliderSpace) * 2);
            final double viewportAspectRatio =
                viewportWidth /
                (bannerWidth / _bannerAspectRatio + (_sliderSpace * 2));

            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: con.maxWidth,
                  height: con.maxWidth * 0.6,
                  child: Assets.media.images.svg.homeOffersBackground.svg(
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _sideMargin - _sliderSpace,
                  ),
                  child: _SlideInOnOpen(
                    child: AppSlider(
                      itemAspectRatio: viewportAspectRatio,
                      sliderSpace: _sliderSpace,
                      showIndicator: false,
                      sliderItems: items
                          .map(
                            (BannerModel banner) =>
                                _TopBannerItem(banner: banner),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Plays the banner's entrance once, the moment it first appears: it starts
/// off-screen and slides into place over [_slide] with an ease-out curve.
///
/// It enters travelling the same way the carousel later auto-plays, so the
/// entrance reads as the first page turn rather than a move against it. Per
/// the motion rule on [AppSlider] that sweep runs right-to-left in Arabic and
/// left-to-right in English, so the banner starts off the page's *start*
/// (leading) edge in both — the right in Arabic, the left in English.
///
/// This is the original single-banner animation (`_AnimatedOffersBanner`),
/// minus its forever loop: the carousel auto-plays now, so snapping it back
/// off-side every few seconds would fight it. [TweenAnimationBuilder] runs a
/// tween with a non-null `begin` on its first build, so the entrance needs no
/// controller, timer or `dispose` of its own.
class _SlideInOnOpen extends StatelessWidget {
  const _SlideInOnOpen({required this.child});

  static const Duration _slide = Duration(milliseconds: 600);

  /// How far off-side the banner starts, as a fraction of its own width.
  static const double _offSide = 1.15;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // A `Transform`, so no `saveLayer`; the boundary keeps the 600 ms of
    // repaints off the starburst behind it and the feed around it.
    return RepaintBoundary(
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(
          begin: Offset(isRtl ? _offSide : -_offSide, 0),
          end: Offset.zero,
        ),
        duration: _slide,
        curve: Curves.easeOut,
        builder: (BuildContext context, Offset offset, Widget? child) =>
            FractionalTranslation(translation: offset, child: child),
        child: child,
      ),
    );
  }
}

/// A single tappable header banner. Shows the locale-specific artwork (falling
/// back to the generic image) and routes the tap by [BannerModel.linkType].
class _TopBannerItem extends StatelessWidget {
  const _TopBannerItem({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.locale.languageCode == 'ar';
    final String imageUrl =
        (isAr ? banner.imageAr : banner.imageEn) ?? banner.image ?? '';

    final AppColorScheme colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            HomeTopBannerSectionView._radius,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
            ),
          ],
        ),
        // Both extents are given so `BoxFit.cover` fills the banner box; with
        // a null height the image sizes itself from its own aspect ratio and
        // letterboxes inside it instead.
        child: AppCachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    // Product taps work; category taps need a slug the `/api/v1/banners`
    // endpoint doesn't emit yet (it sends category ids only), so they stay
    // inert. ponytail: wire category nav once the payload carries a slug.
    if (banner.linkType == 'product' && banner.productSlug != null) {
      context.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: banner.productSlug,
      );
    } else if (banner.linkType == 'category' && banner.categorySlug != null) {
      context.pushNamed(
        AppRoutes.categoryDetailsScreen,
        extra: CategoryModel(slug: banner.categorySlug),
      );
    }
  }
}

/// Rounded shimmer placeholder shown while the banners request is in flight.
class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(
            HomeTopBannerSectionView._radius,
          ),
        ),
      ),
    );
  }
}
