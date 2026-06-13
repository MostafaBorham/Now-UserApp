import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/common/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/components/field_input_borders.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/app_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/home_banner_slider.dart';
import 'package:nowdelivery_user_app/view/widgets/home_categories_section.dart';
import 'package:nowdelivery_user_app/view/widgets/home_search_field.dart';
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
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              spacing: 5,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                  color: colors.onSecondary
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
                                    colorFilter: ColorFilter.mode(colors.onSecondary, BlendMode.srcIn)
                                  ),
                                  AutoSizeText(
                                    'gada, saudia 23 st',
                                    style: AppTextStyles.style12Regular.copyWith(
                                      color: colors.onSecondary
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
                            offset: Offset(1,1),
                            textStyle: AppTextStyles.style10Bold,
                            padding: EdgeInsets.all(3),
                            backgroundColor: colors.errorContainer,
                            child: Assets.media.images.svg.alertIcon.svg(
                              width: 35.sp,
                            ),
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
                    Assets.media.images.svg.whiteWaveBackground.svg(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(top: 30),
                      child: Column(
                        spacing: 10,
                        children: [
                          HomeCategoriesSection(),
                          SizedBox(
                              height: 200,
                              child: TopBrandsSection()),
                          Container(
                            width: double.infinity,
                            height: 250.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  colors.tertiary.withValues(alpha: 0.2),
                                  colors.onPrimary,
                                ],
                              ),
                            ),
                            child: Column(
                              spacing: 15,
                              children: [
                                ShowMoreItemsHeader(headerTitle: LangKeys.mostPopularKey.tr(),),
                                Expanded(
                                  child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) => MostPopularItem(
                                      ), separatorBuilder: (context, index) => 5.wSpace, itemCount: 5),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
