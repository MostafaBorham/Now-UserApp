import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';

class Search2BannersSlider extends StatelessWidget {
  const Search2BannersSlider({super.key});

  static const double _bannerAspectRatio = 355 / 100;
  static const double _sliderSpace = 8;
  static const double _sliderViewportFraction = 0.9;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, con) {
        final double bannerWidth =
            con.maxWidth * _sliderViewportFraction - (_sliderSpace * 2);
        final double sliderHeight =
            bannerWidth / _bannerAspectRatio + (_sliderSpace * 2);

        return AppSlider(
          itemAspectRatio: con.maxWidth / sliderHeight,
          sliderSpace: _sliderSpace,
          showIndicator: false,
          sliderItems: [
            for (final String imageUrl in const <String>[
              'https://picsum.photos/seed/nowbanner1/710/200',
              'https://picsum.photos/seed/nowbanner2/710/200',
              'https://picsum.photos/seed/nowbanner3/710/200',
            ])
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppCachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
          ],
        );
      },
    );
  }
}
