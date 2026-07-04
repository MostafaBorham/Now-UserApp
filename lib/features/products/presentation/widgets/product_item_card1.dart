import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_item_quantity_button/primary_item_quantity_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class ProductItemCard1 extends StatefulWidget {
  const ProductItemCard1({super.key});

  @override
  State<ProductItemCard1> createState() => _ProductItemCard1State();
}

class _ProductItemCard1State extends State<ProductItemCard1> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, con) {
        return Card(
          elevation: 3,
          color: colors.onPrimary,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.brCircular16,
          ),
          child: Column(
            spacing: 5,
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                      ).copyWith(top: 12),
                      child: Stack(
                        children: [
                          Column(
                            spacing: 4,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    con.maxWidth * 0.04,
                                  ),
                                  child: AppCachedNetworkImage(
                                    imageUrl:
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              AppRateWidget(
                                starColor: colors.onSecondaryContainer,
                                rateRatio: '4',
                                rateColor: colors.onSurface,
                                size: con.maxWidth * 0.1,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer,
                                    borderRadius: BorderRadiusDirectional.only(
                                      topEnd: Radius.circular(
                                        con.maxWidth * 0.1,
                                      ),
                                      bottomEnd: Radius.circular(
                                        con.maxWidth * 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '50%',
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: con.maxWidth * 0.06,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 8.0,
                                  ),
                                  child: CircularAppFavouriteIcon(
                                    size: con.maxWidth * 0.08,
                                    isFavourite: false,
                                    onFavouriteChanged: (currentFavourite) {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 8,
                      end: 2,
                      child: Material(
                        elevation: 1,
                        shape: CircleBorder(),
                        child: CircularBrandLogo(
                          radius: con.maxWidth * 0.1,
                          backgroundColor: colors.onPrimary,
                          logoUrl:
                              'https://salogos.b-cdn.net/logos/png/1774894927785-pfguz6z7.png',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0).copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 7,
                  children: [
                    Text(
                      'feta cheese',
                      style: AppTextStyles.style18Bold.copyWith(
                        color: colors.onTertiaryFixed,
                        fontSize: con.maxWidth * 0.1,
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              textDirection: TextDirection.ltr,
                              spacing: 5,
                              children: [
                                OldPriceWidget(
                                  color: colors.inversePrimary,
                                  price: '10',
                                  size: con.maxWidth * 0.04,
                                ),
                                NewPriceWidget(
                                  color: colors.onSecondary,
                                  price: '10',
                                  size: con.maxWidth * 0.08,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ReverseWidget(
                                child: PrimaryItemQuantityButton(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
