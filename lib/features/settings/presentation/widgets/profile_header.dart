import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/arrow_back_button.dart';






class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key, this.title = 'Profile', this.onBack});

  final String title;



  final VoidCallback? onBack;


  static const double _waveAspect = 41 / 390;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    final double width = MediaQuery.of(context).size.width;

    final double waveHeight = (width + 2) * _waveAspect;
    final double headerHeight = topInset + 120;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ColoredBox(color: context.colors.surface),
          ),
          Positioned(
            top: topInset + 25,
            left: 68,
            right: 68,
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.colors.tertiaryContainer,
                ),
              ),
            ),
          ),
          if (onBack != null)
            Positioned(
              top: topInset + 20,
              left: 16,
              child: _BackButton(onTap: onBack!),
            ),
          Positioned(
            left: -1,
            right: -1,
            bottom: -1,
            child: Assets.media.images.svg.wave.svg(
              fit: BoxFit.fill,
              height: waveHeight,
            ),
          ),
        ],
      ),
    );
  }
}


class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ArrowBackButton(onTap: onTap),
    );
  }
}

