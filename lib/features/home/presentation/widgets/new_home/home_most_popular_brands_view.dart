import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class HomeMostPopularBrandsView extends StatelessWidget {
  const HomeMostPopularBrandsView({super.key});

  static const List<({String name, String logo})> _brands = [
    (name: 'Jarir', logo: 'https://picsum.photos/seed/jarir/100'),
    (name: 'KFC', logo: 'https://picsum.photos/seed/kfc/100'),
    (name: 'Starbucks', logo: 'https://picsum.photos/seed/starbucks/100'),
    (name: 'Dunkin', logo: 'https://picsum.photos/seed/dunkin/100'),
    (name: 'McDonald\'s', logo: 'https://picsum.photos/seed/mcdonalds/100'),
    (name: 'Pizza Hut', logo: 'https://picsum.photos/seed/pizzahut/100'),
    (name: 'Burger King', logo: 'https://picsum.photos/seed/burgerking/100'),
    (name: 'Baskin', logo: 'https://picsum.photos/seed/baskin/100'),
  ];

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        final double cardWidth = con.maxWidth * 0.4;
        final double logoSize = con.maxWidth * 0.13;
        final double cardHeight = logoSize + 24;
        final int columnCount = (_brands.length / 2).ceil();

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
                    'Best Brands',
                    style: TextStyle(
                      fontSize: con.maxWidth * 0.052,
                      color: colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: con.maxWidth * 0.032,
                      color: colors.black,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.black,
                    ),
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
                    final int topIndex = index * 2;
                    final int bottomIndex = topIndex + 1;
                    return Column(
                      spacing: 12,
                      children: [
                        _BrandCard(
                          name: _brands[topIndex].name,
                          logo: _brands[topIndex].logo,
                          width: cardWidth,
                          height: cardHeight,
                          logoSize: logoSize,
                        ),
                        if (bottomIndex < _brands.length)
                          _BrandCard(
                            name: _brands[bottomIndex].name,
                            logo: _brands[bottomIndex].logo,
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
    required this.name,
    required this.logo,
    required this.width,
    required this.height,
    required this.logoSize,
  });

  final String name;
  final String logo;
  final double width;
  final double height;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: width * 0.13,
                color: colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AppCachedNetworkImage(
              imageUrl: logo,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
