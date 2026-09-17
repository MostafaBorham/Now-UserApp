import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/logos/circular_brand_logo.dart';

enum LiveOrderStepState { done, going, notTrack }

class LiveOrderTrackCard extends StatelessWidget {
  const LiveOrderTrackCard({
    super.key,
    required this.remainingMinutes,
    required this.logoUrl,
    required this.steps,
    this.onTap,
  });

  final int remainingMinutes;
  final String logoUrl;
  final List<(String, LiveOrderStepState)> steps;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary500Main),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.flip(
                flipX: !context.isRTL,
                child: Assets.media.images.svg.liveOrderCardBackground.svg(
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircularBrandLogo(radius: 20, logoUrl: logoUrl),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${LangKeys.estimatedDeliveryTimeKey.tr()} ',
                                style: TextStyle(color: colors.neutral1200),
                              ),
                              TextSpan(
                                text:
                                    '$remainingMinutes ${LangKeys.minutesKey.tr()}',
                                style: TextStyle(color: colors.primary500Main),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < steps.length; i++) ...[
                        if (i > 0)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 9),
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: steps[i - 1].$2 ==
                                        LiveOrderStepState.done
                                    ? colors.green500
                                    : colors.primary100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StepIcon(state: steps[i].$2),
                            const SizedBox(height: 4),
                            Text(
                              steps[i].$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.neutral1200,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.state});

  final LiveOrderStepState state;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    switch (state) {
      case LiveOrderStepState.done:
        return Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.green500,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 13, color: colors.white),
        );
      case LiveOrderStepState.going:
        return Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primary500Main.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.primary500Main,
              shape: BoxShape.circle,
            ),
          ),
        );
      case LiveOrderStepState.notTrack:
        return SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary100,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
    }
  }
}
