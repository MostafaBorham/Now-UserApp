import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/previous_price_with_currency.dart';

import 'package:nowdelivery_user_app/core/presentation/widgets/price_with_currency.dart';

class HomeProductItem extends StatelessWidget {
  const HomeProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 150,
          width: 150,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            borderRadius: AppBorderRadius.brCircular8
          ),
          child: CachedNetworkImage(imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1280px-Tomato_je.jpg',fit: BoxFit.cover,),
        ),
        AutoSizeText('product123',style: AppTextStyles.style14SemiBold.copyWith(
          color: colors.onTertiaryFixed
        ),),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            PriceWithCurrency(color: colors.tertiaryFixed,price: '20',),
            PreviousPriceWithCurrency(),
          ],
        )
      ],
    );
  }
}
