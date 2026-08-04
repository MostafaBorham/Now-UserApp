import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/best_nearby_stores_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_all_stores_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_categories_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_offers_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/most_popular_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/top_brands_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/white_app_logo.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
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
    final AppColorScheme colors = context.colors;
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
                  WhiteAppLogo(size: 134),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.transparent,
                        child: CachedNetworkImage(
                          imageUrl: '',
                          placeholder: (context, url) =>
                              CircularProgressIndicator(
                                padding: EdgeInsets.all(10),
                                backgroundColor: colors.white,
                                color: colors.primary500Main,
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
                              color: colors.black,
                            ),
                            maxLines: 1,
                          ),
                          Row(
                            spacing: 5,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Assets.media.images.svg.locationIcon.svg(
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                              AutoSizeText(
                                'gada, saudia 23 st',
                                style: AppTextStyles.style12Regular.copyWith(
                                  color: colors.black,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () => context.pushNamed(AppRoutes.notificationsScreen,
                        ),
                        child: Badge.count(
                          count: 2,
                          offset: Offset(1, 1),
                          textColor: colors.white,
                          textStyle: AppTextStyles.style14SemiBold,
                          padding: EdgeInsets.all(3),
                          backgroundColor: colors.errorContainer,
                          child: Assets.media.images.svg.alertIcon.svg(
                            width: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSearchField(),
                  AppSlider(
                    sliderItems: [Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        borderRadius: AppBorderRadius.brCircular16,
                      ),
                      child: AppCachedNetworkImage(
                        imageUrl:
                            'https://img.magnific.com/free-vector/stylish-big-sale-event-banner-buy-save-upto-50-percent_1017-59087.jpg?semt=ais_hybrid&w=740&q=80',
                      ),
                    ),],
                    itemAspectRatio: 2,
                    sliderSpace: 1,
                  ),
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
                  color: colors.white,
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
                      SizedBox(height: 350, child: MostPopularSection()),
                      SizedBox(height: 240, child: BestNearbyStoresSection()),
                      SizedBox(height: 350, child: HomeOffersSection()),
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
                                        'Big Grocery Sale',
                                        style: AppTextStyles.style20Bold
                                            .copyWith(color: colors.white),
                                        maxLines: 1,
                                      ),
                                      AutoSizeText(
                                        'Buy 1 Get 1 Free',
                                        style: AppTextStyles.style12Medium
                                            .copyWith(color: colors.white),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                  CircularBrandLogo(
                                    radius: 35,
                                    elevation: 1,
                                    backgroundColor: colors.white,
                                    logoUrl:
                                        'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => context.pushNamed(AppRoutes.storeDetailsScreen),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.white,
                                    borderRadius: AppBorderRadius.brCircular8,
                                  ),
                                  child: AutoSizeText(
                                    LangKeys.shopNowKey.tr(),
                                    style: AppTextStyles.style16SemiBold.copyWith(
                                      color: colors.black,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 400, child: HomeAllStoresSection()),
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
