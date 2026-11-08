import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';

class Search2BackButton extends StatelessWidget {
  const Search2BackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double size = MediaQuery.sizeOf(context).width * 0.1;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed ?? () => context.pop(),
      child: ReverseWidget(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.black.withValues(alpha: 0.25),
                blurRadius: 1.5,
              ),
            ],
          ),
          child: Assets.media.images.svg.appBackArrow.svg(
            fit: BoxFit.contain,
            width: size / 2,
          ),
        ),
      ),
    );
  }
}
