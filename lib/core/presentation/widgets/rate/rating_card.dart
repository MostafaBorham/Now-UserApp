import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:simple_animated_rating_bar/simple_animated_rating_bar.dart';
import 'package:simple_animated_rating_bar/utils/arb_type.dart';

/// Maps a star count (0–5) to the emoji + label shown in the emotion pill.
/// Kept as data (label key + emoji) so the wording stays in the lang JSON and
/// the emoji — a presentation detail — stays here in Dart.
({String labelKey, String emoji}) _emotionForRating(int rating) {
  return switch (rating) {
    <= 0 => (labelKey: LangKeys.ratingVeryBadKey, emoji: '😡'),
    1 => (labelKey: LangKeys.ratingBadKey, emoji: '😞'),
    2 => (labelKey: LangKeys.ratingAcceptableKey, emoji: '😐'),
    3 => (labelKey: LangKeys.ratingFairKey, emoji: '🙂'),
    4 => (labelKey: LangKeys.ratingGoodKey, emoji: '😊'),
    _ => (labelKey: LangKeys.ratingExcellentKey, emoji: '😍'),
  };
}

class RatingCard extends StatefulWidget {
  const RatingCard({
    super.key,
    required this.title,
    this.initialRating = 4,
    this.onRatingChanged,
  });

  final String title;

  /// Star value the card opens on (0–5).
  final int initialRating;

  /// Fires the current star value whenever the user changes the rating.
  final ValueChanged<int>? onRatingChanged;

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  late int _rating = widget.initialRating;

  void _onRatingChanged(int rating) {
    if (rating != _rating) {
      setState(() => _rating = rating);
    }
    widget.onRatingChanged?.call(rating);
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final ({String labelKey, String emoji}) emotion =
        _emotionForRating(_rating);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.brCircular14,
        border: Border.all(
          color: colors.primary500Main,
          width: 1.5,
        ),
      ),
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: AppTextStyles.style18Medium.copyWith(color: colors.black),
          ),
          Text(
            LangKeys.ratingHelpsImproveServiceKey.tr(),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: AppTextStyles.style14Regular.copyWith(
              color: colors.neutral500,
            ),
          ),

          // Emotion pill: emoji + label reflecting the current star value,
          // swapped smoothly whenever the rating changes.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [colors.secondary100, colors.primary100],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '${emotion.emoji}  ${emotion.labelKey.tr()}',
                key: ValueKey<String>(emotion.labelKey),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.visible,
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.black,
                ),
              ),
            ),
          ),

          AnimatedRatingBar(
            animationType: ARBAnimationType.bounce,
            emptyWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Assets.media.images.svg.orderStarRate.svg(
                width: 20,
                colorFilter: ColorFilter.mode(
                  colors.neutral400.withValues(alpha: 0.3),
                  BlendMode.srcIn,
                ),
              ),
            ),
            fullWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Assets.media.images.svg.orderStarRate.svg(
                width: 20,
                colorFilter: ColorFilter.mode(colors.surface, BlendMode.srcIn),
              ),
            ),
            initialValue: widget.initialRating,
            onRatingChanged: _onRatingChanged,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ),
    );
  }
}
