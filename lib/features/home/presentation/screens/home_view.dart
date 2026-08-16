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
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/best_nearby_stores_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_all_stores_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_categories_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/home_offers_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_search_field.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_app_category_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_never_miss_offers_section.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/top_brands_section.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/white_app_logo.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_header_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_most_popular_brands_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_offers_section_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_categories_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_top_category_item.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          HomeHeaderView(),
          HomeOffersSectionView(),
          HomeMostPopularBrandsView(),
          HomeTopCategoriesView(),
          AspectRatio(
              aspectRatio: 1.47,
              child: BestNearbyStoresSection()),
          AspectRatio(
              aspectRatio: .7,
              child: HomeNeverMissOffersSection()),
          AspectRatio(
              aspectRatio: 1.1,
              child: HomeAppCategorySectionView()),
          AspectRatio(
              aspectRatio: 1.1,
              child: HomeAppCategorySectionView()),
          AspectRatio(
              aspectRatio: 1.1,
              child: HomeAppCategorySectionView()),
        ],
      ),
    );
  }
}