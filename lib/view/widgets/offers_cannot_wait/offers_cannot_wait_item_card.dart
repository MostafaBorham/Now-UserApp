import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_item_quantity_button/add_to_cart_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_item_quantity_button/add_to_cart_counter_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/home/circular_brand_logo.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/app_favourite_icon.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/buttons/primary_item_quantity_button/primary_item_quantity_button.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/reverse_widget.dart';
import '../shared/price_with_currency.dart';
import '../shared/previous_price_with_currency.dart';

class OffersCannotWaitItemCard extends StatefulWidget {
  const OffersCannotWaitItemCard({super.key});

  @override
  State<OffersCannotWaitItemCard> createState() =>
      _OffersCannotWaitItemCardState();
}

class _OffersCannotWaitItemCardState extends State<OffersCannotWaitItemCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context,con) {
        return Card(
          elevation: 3,
          color: colors.onPrimary,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.brCircular16),
          child: Column(
            spacing: 5,
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(top: 12),
                      child: Stack(
                        children: [
                          Column(
                            spacing: 4,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(con.maxWidth*0.04),
                                  child: AppCachedNetworkImage(
                                    imageUrl:
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTruTN7TKhs6EbZtBGtXkJjLwrXau6sw1eyrA&s',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              Row(
                                spacing: 7,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Assets.media.images.svg.starIcon.svg(width: con.maxWidth*0.1,colorFilter: ColorFilter.mode(colors.onSecondaryContainer, BlendMode.srcIn)),
                                  AutoSizeText(
                                    '4',
                                    style: AppTextStyles.style14Medium.copyWith(
                                      color: colors.onSurface,
                                      fontSize: con.maxWidth*0.1
                                    ),
                                  ),
                                ],
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
                                      topEnd: Radius.circular(con.maxWidth*0.1),
                                      bottomEnd: Radius.circular(con.maxWidth*0.1),
                                    ),
                                  ),
                                  child: Text(
                                    '50%',
                                    style: TextStyle(
                                      color: colors.onPrimary,
                                      fontSize: con.maxWidth*0.06,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    isFavorite = !isFavorite;
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 8.0,
                                    ),
                                    child: AppFavouriteIcon(
                                      size: con.maxWidth*0.08,
                                      isFavourite: isFavorite,
                                    ),
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
                          radius: con.maxWidth*0.1,
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
                          fontSize: con.maxWidth*0.1
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
                                OldPriceWidget(color: colors.inversePrimary, price: '10',size: con.maxWidth*0.04,),
                                NewPriceWidget(color: colors.onSecondary, price: '10',size: con.maxWidth*0.08),
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
                                      child: PrimaryItemQuantityButton())),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
