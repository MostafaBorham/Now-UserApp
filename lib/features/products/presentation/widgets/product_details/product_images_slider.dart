import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/enums/loading_view_types.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/sliders/app_slider.dart';

class ProductImagesSlider extends StatelessWidget {
  const ProductImagesSlider({super.key, required this.images});

  final List<String>? images;

  @override
  Widget build(BuildContext context) {
    final List<String>? images = this.images;
    if (images == null || images.length < 2) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: AppCachedNetworkImage(
          imageUrl: images?.firstOrNull ?? '',
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.contain,
          placeholderType: LoadingViewTypes.circular,
          circularProgressSize: 50,
        ),
      );
    }
    return AppSlider(
      sliderItems: images
          .map(
            (String image) => AppCachedNetworkImage(
              imageUrl: image,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.contain,
              placeholderType: LoadingViewTypes.circular,
              circularProgressSize: 50,
            ),
          )
          .toList(),
      fillHeight: true,
    );
  }
}
