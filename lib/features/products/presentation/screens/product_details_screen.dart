import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/widgets/my_orders/order_list_item.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_colors_selector.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_main_info_card.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppWavedScaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colors.errorContainer
                    ),
                    child: Text('10%',style: AppTextStyles.style14Bold.copyWith(
                        color: colors.onPrimary
                    ),),
                  ),
                  CircularAppFavouriteIcon(onFavouriteChanged: (p0) {

                  },),
                ],
              ),
              AppSlider(
                sliderItem: AppCachedNetworkImage(
                  imageUrl:
                      'https://shuttershopegypt.com/wp-content/uploads/2026/01/1727307031_IMG_2344874.webp',
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                itemAspectRatio: 1.5,
              ),
              ProductMainInfoCard(),
              ProductColorsSelector()
            ],
          ),
        ),
        appBarTitle: 'Product Details',
        appBarActions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: colors.onPrimary,
              radius: 25,
              child: Center(
                child: Assets.media.images.svg.shoppingCartIcon.svg(
                  fit: BoxFit.contain,
                  width: 25,
                  colorFilter: ColorFilter.mode(
                    colors.onSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
