import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class HomeMostPopularBrandsView extends StatelessWidget {
  const HomeMostPopularBrandsView({super.key});

  // TODO: temporary placeholder count until brands are fetched from the API.
  static const int _brandsCount = 8;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        final double cardWidth = con.maxWidth * 0.4;
        final double logoSize = con.maxWidth * 0.13;
        final double cardHeight = logoSize + 24;
        final int columnCount = (_brandsCount / 2).ceil();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Most Popular Brands',
                    style: TextStyle(
                      fontSize: con.maxWidth * 0.05,
                      color: colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      Positioned.fill(
                        child: FractionallySizedBox(
                          widthFactor: 0.8,
                          heightFactor: 0.6,
                          alignment: AlignmentDirectional.bottomEnd,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadiusGeometry.circular(100),
                              gradient: LinearGradient(
                                colors: [colors.white,colors.onSecondaryContainer.withValues(alpha: 0.4)],
                                begin: AlignmentDirectional.centerStart,
                                end: AlignmentDirectional.centerEnd,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: con.maxWidth * 0.035,
                          color: colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: cardHeight * 2 + 12,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: columnCount,
                  separatorBuilder: (context, index) => 12.wSpace,
                  itemBuilder: (context, index) {
                    final int bottomIndex = index * 2 + 1;
                    return Column(
                      spacing: 12,
                      children: [
                        _BrandCard(
                          width: cardWidth,
                          height: cardHeight,
                          logoSize: logoSize,
                        ),
                        if (bottomIndex < _brandsCount)
                          _BrandCard(
                            width: cardWidth,
                            height: cardHeight,
                            logoSize: logoSize,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.width,
    required this.height,
    required this.logoSize,
  });

  // TODO: temporary placeholder values until brands are fetched from the API.
  static const String _name = 'KFC';
  static const String _logo =
      'https://www.image2url.com/r2/default/images/1786549005240-05cb0498-26b3-4404-b85b-e936af77e34d.png';

  final double width;
  final double height;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.neutral500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 8,
        children: [
          SizedBox(
            width: width / 3,
            height: logoSize,
            child: CachedNetworkImage(
              imageUrl: _logo,
              width: width / 3,
              height: logoSize,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: Text(
              _name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: width * 0.1,
                color: colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
