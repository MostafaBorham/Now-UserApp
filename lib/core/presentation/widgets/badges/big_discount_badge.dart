import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

class BigDiscountBadge extends StatelessWidget {
  const BigDiscountBadge({
    super.key,
    this.size = 50,
    this.animation = kAlwaysCompleteAnimation,
  });

  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final Animation<double> opacity = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.075, 0.25, curve: Curves.easeOutQuint),
    );
    final Animation<double> turns = Tween<double>(begin: 0.25, end: 0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.075, 0.4, curve: Curves.easeOutQuint),
      ),
    );
    final Animation<double> scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 7.5),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 27.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 55),
    ]).animate(animation);

    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(
        scale: scale,
        child: RotationTransition(
          turns: turns,
          child:
              (context.isRTL
                      ? Assets
                            .media
                            .images
                            .svg
                            .donotMissOffersBadgeDiscountIconArabic
                      : Assets
                            .media
                            .images
                            .svg
                            .donotMissOffersBadgeDiscountIconEnglish)
                  .svg(
                    width: size,
                    height: size * 45 / 50,
                    fit: BoxFit.contain,
                  ),
        ),
      ),
    );
  }
}
