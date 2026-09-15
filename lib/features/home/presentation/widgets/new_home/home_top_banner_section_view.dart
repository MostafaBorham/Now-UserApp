

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








class HomeTopBannerSectionView extends ConsumerWidget {
  const HomeTopBannerSectionView({super.key});



  static const double _bannerAspectRatio = 355 / 118;
  static const double _sideMargin = 17.5;
  static const double _radius = 18;




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















class _SlideInOnOpen extends StatelessWidget {
  const _SlideInOnOpen({required this.child});

  static const Duration _slide = Duration(milliseconds: 600);


  static const double _offSide = 1.15;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;



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



        child: AppCachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {



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
