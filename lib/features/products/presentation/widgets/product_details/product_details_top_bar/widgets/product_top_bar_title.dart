import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_name.dart';

class ProductTopBarTitle extends StatelessWidget {
  const ProductTopBarTitle({
    super.key,
    required this.name,
    required this.progress,
    required this.shift,
    required this.horizontalInset,
  });

  static const double _infoCardTextInset = 16;

  final String name;
  final double progress;
  final double shift;
  final double horizontalInset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, shift),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: lerpDouble(
            _infoCardTextInset,
            horizontalInset,
            progress,
          )!,
        ),
        child: Align(
          alignment: AlignmentDirectional.lerp(
            AlignmentDirectional.centerStart,
            AlignmentDirectional.center,
            progress,
          )!,
          child: ProductDetailsName(
            name: name,
            maxLines: 1,
            collapse: progress,
          ),
        ),
      ),
    );
  }
}
