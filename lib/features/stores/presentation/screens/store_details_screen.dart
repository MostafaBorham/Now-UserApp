import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_header.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_featured_product_card.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_products_filter_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_products_grid.dart';

class StoreDetailsScreen extends StatelessWidget {
  const StoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        appBarTitle: LangKeys.storesKey.tr(),
        appBarActions: [
          InkWell(
            child: CircleAvatar(
              backgroundColor: colors.onPrimary,
              radius: 20,
              child: Center(
                child: Assets.media.images.svg.shoppingCartIcon
                    .svg(
                    fit: BoxFit.contain,
                    width:20,
                  colorFilter: ColorFilter.mode(colors.onSecondary, BlendMode.srcIn),
                ),
              ),
            ),
          )
        ],
        body: ListView(
          children: [
            const StoreFeaturedProductCard(),
            20.hSpace,
            const StoreDiscountCouponsList(),
            20.hSpace,
            const StoreCategoryCirclesList(),
            12.hSpace,
            const StoreProductsFilterBar(),
            16.hSpace,
            const StoreProductsGrid(),
          ],
        ),
      ),
    );
  }
}
