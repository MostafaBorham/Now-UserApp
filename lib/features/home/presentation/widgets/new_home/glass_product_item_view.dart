import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/favourites/circular_app_favourite_icon.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/cart/presentation/widgets/animated_cart_button.dart';

class GlassProductItemView extends StatelessWidget {
  const GlassProductItemView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: 'https://www.image2url.com/r2/default/images/1786611818996-ce0a2e08-e938-4dc2-8a43-f6337ba02bf9.png',
                    width: con.maxWidth * 0.6,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorWidget: (context, url, error) => SizedBox.shrink(),
                    placeholder: (context, url) => SizedBox.shrink(),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ReverseWidget(
                              applyReverse: !context.isRTL,
                              child: Assets.media.images.svg.discountTicketIcon
                                  .svg(width: con.maxWidth * 0.2),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.only(top: 5.0,start: 3),
                              child: Transform.rotate(
                                angle: context.isRTL? -1.1 : 1.1,
                                child: SizedBox(
                                  width: con.maxWidth*0.1,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '50%',
                                      style: TextStyle(
                                        color: colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: con.maxWidth * 0.08,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        CircularAppFavouriteIcon(size: con.maxWidth * 0.1,),
                      ],
                    ),
                  ),
                  LiquidGlassLens(
                    style: const LiquidGlassStyle(
                      shape: LiquidGlassShape.roundedRectangle(
                        cornerRadius: 0,
                        borderWidth: 0,
                        lightIntensity: 0,
                      ),
                      appearance: LiquidGlassAppearance(
                        blur: LiquidGlassBlur(sigmaX: 5, sigmaY: 5),
                      ),
                      refraction: LiquidGlassRefraction(
                        distortionWidth: 0,
                        magnification: 1,
                      ),
                    ),
                    // The lens hugs this Column exactly — same width and height.
                    // A single white line on the top edge only; the other
                    // edges stay borderless.
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        spacing: 5,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ماك بو اير3',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.black,
                                ),
                              ),
                              AppRateWidget(
                                starColor: colors.amber500,
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
                              NewPriceWidget(
                                color: colors.black,
                                price: '2000',
                                size: 16,
                              ),
                              // Reserve the slot the cart control occupies so
                              // the price keeps its place. The real control is a
                              // Stack overlay below, so its counter can expand
                              // over the price/name without shifting them.
                              SizedBox.square(
                                dimension:
                                    MediaQuery.sizeOf(context).width * 0.075,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // The cart control floats at its original bottom-end corner.
              // Living in the card Stack (not the price Row) lets the counter
              // grow up and inward over the price and name when it opens —
              // on top of them and without moving them — while staying fully
              // tappable inside the card bounds. Insets match the glass
              // panel's padding so it lines up with the reserved slot above.
              const PositionedDirectional(
                bottom: 8,
                end: 8,
                child: AnimatedCartButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}
