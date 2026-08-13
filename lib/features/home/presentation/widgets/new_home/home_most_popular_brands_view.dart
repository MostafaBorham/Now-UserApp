import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class HomeMostPopularBrandsView extends StatelessWidget {
  const HomeMostPopularBrandsView({super.key});

  static const int _brandsCount = 8;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        final double cardWidth = con.maxWidth * 0.4;
        final double logoSize = con.maxWidth * 0.13;
        final double cardHeight = logoSize + 24;

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
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _brandsCount,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: cardWidth,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return _BrandCard(
                      width: cardWidth,
                      height: cardHeight,
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
  });

  // TODO: temporary placeholder values until brands are fetched from the API.
  static const String _name = 'KFC';
  static const String _logo =
      'https://www.image2url.com/r2/default/images/1786611818996-ce0a2e08-e938-4dc2-8a43-f6337ba02bf9.png';

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.neutral500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: _logo,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: Text(
              _name,
              maxLines: 1,
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
