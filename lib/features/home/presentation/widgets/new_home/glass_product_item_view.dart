import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';
import 'package:nowdelivery_user_app/features/favourites/presentation/widgets/circular_app_favourite_icon.dart';

class GlassProductItemView extends StatelessWidget {
  const GlassProductItemView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context,con) {
        return Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colors.primaryFixed,
            borderRadius: BorderRadiusGeometry.circular(8),
            image: DecorationImage(
              image: NetworkImage(
                'https://www.image2url.com/r2/default/images/1786611818996-ce0a2e08-e938-4dc2-8a43-f6337ba02bf9.png',
              ),
              fit: BoxFit.contain,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReverseWidget(
                      applyReverse: !context.isRTL,
                      child: Assets.media.images.svg.discountTicketIcon.svg(
                        width: con.maxWidth*0.15
                      )),
                  CircularAppFavouriteIcon(
                    size: con.maxWidth*0.1,
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Iphone',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.black,
                        ),
                      ),
                      AppRateWidget(
                        starColor: colors.onSecondaryContainer,
                        rateRatio: '4.9',
                        rateColor: colors.black,
                        rateCount: '45',
                        size: 14,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NewPriceWidget(color: colors.black, price: '2000',size: 16,),
                      AnimatedCartButton()
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
