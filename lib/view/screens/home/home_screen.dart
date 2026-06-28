import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:motion_tab_bar_v2/motion-badge.widget.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/components/field_input_borders.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/app_borders.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/logos/app_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/home/best_nearby_stores_section.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/home/home_all_stores_section.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/view/widgets/home/home_categories_section.dart';
import 'package:nowdelivery_user_app/view/widgets/home/home_offers_section.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/view/widgets/home/most_popular_section.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/show_more_items_header.dart';
import 'package:nowdelivery_user_app/view/widgets/home/top_brands_section.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/logos/white_app_logo.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  MotionTabBarController? _motionTabBarController;

  @override
  void initState() {
    super.initState();

    //// use "MotionTabBarController" to replace with "TabController", if you need to programmatically change the tab
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textThemes = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ).copyWith(top: 15),
              child: Column(
                spacing: 20,
                children: [
                  /*Container(
                      width: 200,
                      height: 200,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: Svg(Assets.media.images.svg.clipper.path))
                      ),
                      child: CachedNetworkImage(imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg'),
                    ),*/
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
                          placeholder: (context, url) =>
                              CircularProgressIndicator(
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
                        child: Assets.media.images.svg.alertIcon.svg(
                          width: 35.sp,
                        ),
                      ),
                    ],
                  ),
                  AppSearchField(),
                  AppSlider(sliderItem: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 100.h,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.brCircular16
                    ),
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: double.infinity,
                          height: 100.h,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          decoration: BoxDecoration(
                              borderRadius: AppBorderRadius.brCircular16,
                              color: colors.onPrimary,
                              border: AppBorders.b1(colors.inversePrimary)
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        imageUrl: 'https://img.magnific.com/free-vector/stylish-big-sale-event-banner-buy-save-upto-50-percent_1017-59087.jpg?semt=ais_hybrid&w=740&q=80'),
                  ),),
                ],
              ),
            ),
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Assets.media.images.svg.whiteWaveBackground.svg(
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: colors.onPrimary,
                  margin: const EdgeInsets.only(top: 50.0),
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
                      SizedBox(
                        height: 240.h,
                        child: BestNearbyStoresSection(),
                      ),
                      SizedBox(height: 350.h, child: HomeOffersSection()),
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
                                            .copyWith(
                                          color: colors.onPrimary,
                                        ),
                                        maxLines: 1,
                                      ),
                                      AutoSizeText(
                                        'Guest 123',
                                        style: AppTextStyles.style12Medium
                                            .copyWith(
                                          color: colors.onPrimary,
                                        ),
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
                                  LangKeys.shopNowKey.tr(),
                                  style: AppTextStyles.style16SemiBold
                                      .copyWith(color: colors.onSecondary),
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
    );
  }
}
