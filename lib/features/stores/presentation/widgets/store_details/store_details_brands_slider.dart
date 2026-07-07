import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/white_gradient_overlay_effect.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_arrow_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/tab_bars/custom_button_tab_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_category_circles_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_app_bar.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_banner.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_info_header.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_details_products_view.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_details/store_discount_coupons_list.dart';
import 'package:nowdelivery_user_app/features/stores/presentation/widgets/store_info_row.dart';

class StoreDetailsBrandsSlider extends StatelessWidget {
  const StoreDetailsBrandsSlider({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Stack(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'GALAXY',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 90,
                  color: colors.secondaryFixedDim,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                    AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [
                      colors.onPrimary.withValues(
                        alpha: 0.9,
                      ),
                      colors.onPrimary.withValues(
                        alpha: 0.75,
                      ),
                      colors.onPrimary.withValues(
                        alpha: 0.5,
                      ),
                      colors.onPrimary.withValues(
                        alpha: 0.3,
                      ),
                      colors.onPrimary.withValues(
                        alpha: 0.1,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        AppArrowSlider(
          sliderItem: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.circular(
                20,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.secondaryFixedDim
                      .withValues(alpha: 0.3),
                  offset: Offset(0, 10),
                  spreadRadius: 15,
                  blurRadius: 25,
                ),
              ],
            ),
            child: AppCachedNetworkImage(
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              imageUrl:
              'https://www.elsupplier.com/_next/image?url=https://portal.elsupplier.com/backend/public/storage/products/dark-chocolate-bar-732x549-thumbnail604108001.jpg&w=640&q=50',
            ),
          ),
          sliderSpace: 8,
          itemAspectRatio: 1.5,
          activeDotColor: colors.secondaryFixedDim,
          dotColor: colors.onPrimary,
        ),
      ],
    );
  }
}