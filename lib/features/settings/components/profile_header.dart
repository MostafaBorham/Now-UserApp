import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_colors.dart';

/// Yellow header at the top of the screen.
///
/// Fills the area behind the status bar, centers the screen [title], draws
/// the white wave asset along its bottom edge, and — when [onBack] is
/// provided — shows a circular back button on the left.
class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key, this.title = 'Profile', this.onBack});

  final String title;

  /// When non-null a circular back button is shown on the left and this
  /// callback runs when it is tapped.
  final VoidCallback? onBack;

  /// The wave asset keeps a fixed 390 x 41 aspect ratio.
  static const double _waveAspect = 41 / 390;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    final double width = MediaQuery.of(context).size.width;
    // 2px of horizontal overscan so the wave covers the extreme corners.
    final double waveHeight = (width + 2) * _waveAspect;
    final double headerHeight = topInset + 120;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: ColoredBox(color: AppColors.primaryYellow),
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
            child: SvgPicture.asset(
              'assets/svg/wave.svg',
              fit: BoxFit.fill,
              height: waveHeight,
            ),
          ),
        ],
      ),
    );
  }
}

/// White circular back button using the provided chevron asset.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        boxShadow: [
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

class ArrowBackButton extends StatelessWidget {
  const ArrowBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: SvgPicture.asset(
            'assets/svg/arrow-right.svg',
            width: 22,
            height: 22,
          ),
        ),
      ),
    );
  }
}
