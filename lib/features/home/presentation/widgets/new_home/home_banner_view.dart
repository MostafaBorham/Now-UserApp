import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/banner_model.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/utils/open_category.dart';

/// A single full-width promo banner between two home sections.
///
/// [banner] is a feed banner item (`promo_block_middle` / `promo_block_footer`).
/// Only build it when [imageUrlFor] has an image: a slot published without
/// artwork for the current locale is simply left out. It used to fall back to a
/// watermarked Adobe Stock preview, which would have gone in front of every
/// user of the other language.
class HomeBannerView extends ConsumerWidget {
  const HomeBannerView({super.key, required this.banner});

  final BannerModel banner;

  /// The artwork to show for the current locale, or `null` when there is none.
  static String? imageUrlFor(BuildContext context, BannerModel banner) {
    final bool isAr = context.locale.languageCode == 'ar';
    final String? url =
        (isAr ? banner.imageAr : banner.imageEn) ?? banner.image;
    return (url == null || url.isEmpty) ? null : url;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final String? imageUrl = imageUrlFor(context, banner);
    if (imageUrl == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTap(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.black.withValues(alpha: 0.25),
              offset: Offset.zero,
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AppCachedNetworkImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    // Both screens navigate by slug, and the feed sends numeric `product_id` /
    // `main_category_id` only. A category's slug is found among the categories
    // already loaded (`openHomeCategory`); a product tap stays inert until the
    // feed emits `product_slug`, which BannerModel then picks up.
    final String? productSlug = banner.productSlug;
    if (productSlug != null) {
      context.pushNamed(AppRoutes.productDetailsScreen, extra: productSlug);
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
