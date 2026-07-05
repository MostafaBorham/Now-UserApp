import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/old_price_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/rate/app_rate_widget.dart';

class StoreFeaturedProductCard extends StatefulWidget {
  const StoreFeaturedProductCard({super.key});

  @override
  State<StoreFeaturedProductCard> createState() =>
      _StoreFeaturedProductCardState();
}

class _StoreFeaturedProductCardState extends State<StoreFeaturedProductCard> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  static const List<String> _images = [
    'https://images.unsplash.com/photo-1511381939415-e44015466834?w=600',
    'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=600',
    'https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=600',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.08, 0.63],
                    colors: [
                      colors.onSurface.withValues(alpha: 0.35),
                      colors.onErrorContainer,
                    ],
                  ).createShader(rect),
                  child: Text(
                    'GALAXY',
                    style: AppTextStyles.style42Bold.copyWith(
                      fontSize: 72,
                      letterSpacing: -4,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.brCircular20,
                    boxShadow: [
                      BoxShadow(
                        color: colors.onErrorContainer.withValues(alpha: 0.3),
                        blurRadius: 36,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: AppBorderRadius.brCircular20,
                    child: CarouselSlider.builder(
                      carouselController: _controller,
                      itemCount: _images.length,
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 1,
                        onPageChanged: (index, _) =>
                            setState(() => _current = index),
                      ),
                      itemBuilder: (context, index, _) => AppCachedNetworkImage(
                        imageUrl: _images[index],
                        width: double.infinity,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 0,
                child: _CarouselArrow(
                  onTap: () => _controller.previousPage(),
                  isNext: false,
                ),
              ),
              PositionedDirectional(
                end: 0,
                child: _CarouselArrow(
                  onTap: () => _controller.nextPage(),
                  isNext: true,
                ),
              ),
            ],
          ),
        ),
        12.hSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: List.generate(
            _images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _current == index ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: AppBorderRadius.brCircular6,
                color: _current == index
                    ? colors.onErrorContainer
                    : colors.inversePrimary,
              ),
            ),
          ),
        ),
        16.hSpace,
        const _FeaturedProductDetails(),
      ],
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.onTap, required this.isNext});
  final VoidCallback onTap;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: colors.onPrimary,
        child: Icon(
          isNext ? Icons.chevron_right : Icons.chevron_left,
          color: colors.onSecondary,
        ),
      ),
    );
  }
}

class _FeaturedProductDetails extends StatelessWidget {
  const _FeaturedProductDetails();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: AppBorderRadius.brCircular20,
        boxShadow: [
          BoxShadow(
            color: colors.onSecondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            'Dark Chocolate',
            style: AppTextStyles.style12Medium.copyWith(
              color: colors.onSurface,
            ),
          ),
          Text(
            'Dark Galaxy',
            style: AppTextStyles.style20Bold.copyWith(
              color: colors.onTertiaryFixed,
            ),
          ),
          Text(
            'شوكولاتة داكنة غنية بنسبة ٧٠٪ كاكاو. لعشاق النكهة',
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.onSurface,
            ),
          ),
          8.hSpace,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                AppRateWidget(
                  starColor: colors.onSecondaryContainer,
                  rateRatio: '4.8',
                  rateCount: '2.5K',
                  rateColor: colors.onSecondary,
                  size: 14,
                ),
              ],
            ),
          ),
          Divider(color: colors.surfaceContainerLow, height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: AppBorderRadius.brCircular6,
                        ),
                        child: Text(
                          '-27%',
                          style: AppTextStyles.style12SemiBold.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                      OldPriceWidget(
                        color: colors.inversePrimary,
                        price: '13',
                        size: 14,
                      ),
                    ],
                  ),
                  NewPriceWidget(color: colors.onSecondary, price: '10', size: 28),
                ],
              ),
              const _AddToCartButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: AppBorderRadius.brCircular12,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: colors.onErrorContainer,
          borderRadius: AppBorderRadius.brCircular12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Assets.media.images.svg.shoppingCartIcon.svg(
              width: 16,
              colorFilter: ColorFilter.mode(colors.onPrimary, BlendMode.srcIn),
            ),
            Text(
              LangKeys.addToCartKey.tr(),
              style: AppTextStyles.style14SemiBold.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
