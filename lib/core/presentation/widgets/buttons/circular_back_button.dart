import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class CircularBackButton extends StatelessWidget {
  const CircularBackButton({super.key, this.size = 25, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      onTap: onTap ?? () => context.pop(),
      child: ReverseWidget(
        child: CircleAvatar(
          backgroundColor: colors.white,
          radius: size,
          child: Center(
            child: Assets.media.images.svg.appBackArrow.svg(
              fit: BoxFit.contain,
              width: size,
            ),
          ),
        ),
      ),
    );
  }
}
