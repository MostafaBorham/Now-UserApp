import 'package:easy_localization/easy_localization.dart';
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

  /// Aspect ratio of the header banner. Lower = taller/bigger banner.
  static const double _aspectRatio = 2.7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<BannerModel>> banners = ref.watch(
      getHeaderBannersProvider,
    );

    return banners.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: AspectRatio(aspectRatio: _aspectRatio, child: _BannerSkeleton()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (List<BannerModel> items) {
        if (items.isEmpty) return const SizedBox.shrink();
        // The decorative starburst (moved here from HomeOffersSectionView)
        // keeps its natural box — full device width, `width * 0.6` tall — and
        // the banner is centered on top of it, so it bleeds above and below.
        return LayoutBuilder(
          builder: (context, con) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppSlider(
                    itemAspectRatio: _aspectRatio,
                    showIndicator: false,
                    sliderItems: items
                        .map(
                          (BannerModel banner) =>
                              _TopBannerItem(banner: banner),
                        )
                        .toList(),
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AppCachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
