// `easy_localization` re-exports intl's `TextDirection`, which collides with
// the framework's own (used by `_SlideInOnOpen`).
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/utils/open_category.dart';

/// The top banner carousel of the special offers section, shown under the
/// auto-scrolling offers list.
///
/// [banners] are the items of the feed's `top_banner` section: every visible
/// `header_main_page` banner, so there is no second request. One banner
/// renders as a static image, many as an auto-playing carousel (both via
/// [AppSlider]). Silent when empty — it is decorative, so it just takes no
/// space.
class HomeTopBannerSectionView extends StatelessWidget {
  const HomeTopBannerSectionView({
    super.key,
    this.banners = const <BannerModel>[],
    this.isLoading = false,
  });

  final List<BannerModel> banners;

  /// Shows the banner's skeleton, in the carousel's own box, while the feed
  /// loads.
  final bool isLoading;

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
  Widget build(BuildContext context) {
    if (isLoading) {
      // The vertical padding is the slider's own, above and below the banner,
      // so swapping the skeleton for the carousel moves nothing.
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _sideMargin,
          vertical: _sliderSpace,
        ),
        child: AspectRatio(
          aspectRatio: _bannerAspectRatio,
          child: _BannerSkeleton(),
        ),
      );
    }
    if (banners.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, con) {
        final double bannerWidth = con.maxWidth - (_sideMargin * 2);
        final double viewportWidth =
            con.maxWidth - ((_sideMargin - _sliderSpace) * 2);
        final double viewportAspectRatio =
            viewportWidth /
            (bannerWidth / _bannerAspectRatio + (_sliderSpace * 2));

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _sideMargin - _sliderSpace,
          ),
          child: _SlideInOnOpen(
            child: AppSlider(
              itemAspectRatio: viewportAspectRatio,
              sliderSpace: _sliderSpace,
              showIndicator: false,
              sliderItems: banners
                  .map((BannerModel banner) => _TopBannerItem(banner: banner))
                  .toList(),
            ),
          ),
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
class _TopBannerItem extends ConsumerWidget {
  const _TopBannerItem({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAr = context.locale.languageCode == 'ar';
    final String imageUrl =
        (isAr ? banner.imageAr : banner.imageEn) ?? banner.image ?? '';

    final AppColorScheme colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context, ref),
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

  void _onTap(BuildContext context, WidgetRef ref) {
    // The feed sends a banner's `product_id` / `main_category_id` only. A
    // category's slug is found among the categories already loaded
    // (`openHomeCategory`); a product tap stays inert until the feed emits
    // `product_slug` (backend ticket T18), which BannerModel then picks up.
    if (banner.linkType == 'product' && banner.productSlug != null) {
      context.pushNamed(
        AppRoutes.productDetailsScreen,
        extra: banner.productSlug,
      );
    } else if (banner.linkType == 'category') {
      openHomeCategory(
        context,
        ref,
        id: banner.mainCategoryId,
        slug: banner.categorySlug,
      );
    }
  }
}

/// Rounded shimmer placeholder shown while the feed loads.
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
