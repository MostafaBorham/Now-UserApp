import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/components/field_input_borders.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/app_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/best_nearby_stores_section.dart';
import 'package:nowdelivery_user_app/view/widgets/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/home_all_stores_section.dart';
import 'package:nowdelivery_user_app/view/widgets/home_banner_slider.dart';
import 'package:nowdelivery_user_app/view/widgets/home_categories_section.dart';
import 'package:nowdelivery_user_app/view/widgets/home_offers_section.dart';
import 'package:nowdelivery_user_app/view/widgets/home_search_field.dart';
import 'package:nowdelivery_user_app/view/widgets/most_popular_section.dart';
import 'package:nowdelivery_user_app/view/widgets/show_more_items_header.dart';
import 'package:nowdelivery_user_app/view/widgets/top_brands_section.dart';
import 'package:nowdelivery_user_app/view/widgets/white_app_logo.dart';

import '../widgets/most_popular_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colors.onSecondaryFixed,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
                    top: 15
                ),
                child: Column(
                  spacing: 20,
                  children: [
                    WhiteAppLogo(size: 134.sp),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25.w,
                          backgroundColor: Colors.transparent,
                          child: CachedNetworkImage(
                            imageUrl: '',
                            placeholder: (context, url) => CircularProgressIndicator(
                              padding: EdgeInsets.all(10),
                              backgroundColor: colors.onPrimary,
                              color: colors.primary,
                            ),
                            errorWidget: (context, url, error) => Assets
                                .media
                                .images
                                .png
                                .profileImgPlacholder
                                .image(fit: BoxFit.cover),
                          ),
                        ),
                        Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              'Guest 123',
                              style: AppTextStyles.style20SemiBold.copyWith(
                                color: colors.onSecondary,
                              ),
                              maxLines: 1,
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Assets.media.images.svg.locationIcon.svg(
                                  width: 16.w,
                                  height: 16.w,
                                  colorFilter: ColorFilter.mode(
                                    colors.onSecondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                AutoSizeText(
                                  'gada, saudia 23 st',
                                  style: AppTextStyles.style12Regular.copyWith(
                                    color: colors.onSecondary,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Badge.count(
                          count: 2,
                          offset: Offset(1, 1),
                          textStyle: AppTextStyles.style10Bold,
                          padding: EdgeInsets.all(3),
                          backgroundColor: colors.errorContainer,
                          child: Assets.media.images.svg.alertIcon.svg(width: 35.sp),
                        ),
                      ],
                    ),
                    HomeSearchField(),
                    HomeBannerSlider(),
                  ],
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Assets.media.images.svg.whiteWaveBackground.svg(
                      fit: BoxFit.fill
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Column(
                      spacing: 20,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: HomeCategoriesSection(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TopBrandsSection(),
                        ),
                        SizedBox(height: 350.h, child: MostPopularSection()),
                        SizedBox(height: 200.h, child: BestNearbyStoresSection()),
                        SizedBox(height: 300.h, child: HomeOffersSection()),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                'https://static.vecteezy.com/system/resources/thumbnails/052/302/728/small/in-a-grocery-stores-aisles-theres-a-vibrant-display-featuring-an-array-of-fresh-fruits-and-vegetables-photo.jpg',
                              ),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          'Guest 123',
                                          style: AppTextStyles.style20Bold
                                              .copyWith(color: colors.onPrimary),
                                          maxLines: 1,
                                        ),
                                        AutoSizeText(
                                          'Guest 123',
                                          style: AppTextStyles.style12Medium
                                              .copyWith(color: colors.onPrimary),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                    CircularBrandLogo(
                                      radius: 35.r,
                                      logoUrl:
                                          'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary,
                                    borderRadius: AppBorderRadius.brCircular8,
                                  ),
                                  child: AutoSizeText(
                                    'Shop Now',
                                    style: AppTextStyles.style16SemiBold.copyWith(
                                      color: colors.onSecondary,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 400.h, child: HomeAllStoresSection()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
