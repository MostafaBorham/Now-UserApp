import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

class ProductDetailsName extends StatelessWidget {
  const ProductDetailsName({
    super.key,
    required this.name,
    this.maxLines,
    this.collapse = 0,
  });

  static const double fontSize = 22;
  static const double lineHeight = 1.3;
  static const double _collapsedFontSize = 18;

  final String name;
  final int? maxLines;
  final double collapse;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      style: AppTextStyles.style24Bold.copyWith(
        color: context.colors.black,
        fontSize: lerpDouble(fontSize, _collapsedFontSize, collapse),
        height: lineHeight,
      ),
    );
  }
}
