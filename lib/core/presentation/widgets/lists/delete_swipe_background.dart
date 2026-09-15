import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';




class DeleteSwipeBackground extends StatelessWidget {
  const DeleteSwipeBackground({
    super.key,
    required this.alignment,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final AlignmentGeometry alignment;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: context.colors.onError,
        borderRadius: borderRadius,
      ),
      child: Assets.media.images.svg.deleteIcon.svg(
        width: 26,
        height: 26,
        colorFilter: ColorFilter.mode(context.colors.white, BlendMode.srcIn),
      ),
    );
  }
}
