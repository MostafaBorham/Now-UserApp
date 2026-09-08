import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:simple_animated_rating_bar/simple_animated_rating_bar.dart';
import 'package:simple_animated_rating_bar/utils/arb_type.dart';

/// Fired when the user settles on a new star value. Carries both the star
/// [rating] and the matching emotion [comment] ("Excellent 😍") so the caller
/// doesn't re-derive the wording — the emotion mapping lives here.
typedef RatingChangedCallback = void Function(int rating, String comment);

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

/// A controlled rating card: it renders the committed [rating] and reports the
/// user's new pick through [onRatingChanged], but never advances the committed
/// value (nor the emotion text) on its own — the parent decides that, typically
/// after the rating request succeeds, by passing a new [rating].
///
/// While [isLoading] the fill animates back and forth between the committed
/// value and the value the user just picked, using the stars' own colors (no
/// dimming), and the bar ignores touch. When the request settles the parent
/// flips [isLoading] off and either commits the new [rating] (success — the
/// fill stops on the picked star) or leaves it unchanged (error — the fill
/// snaps back to where it was); the emotion text follows the committed value.
class RatingCard extends StatefulWidget {
  const RatingCard({
    super.key,
    required this.title,
    this.rating = 1,
    this.isLoading = false,
    this.onRatingChanged,
  });

  final String title;

  /// The committed star value the card shows (0–5). Owned by the parent.
  final int rating;

  /// While true the fill oscillates between the old and picked value and the
  /// bar ignores touch, until the parent commits/reverts and flips it off.
  final bool isLoading;

  /// Fires the settled star value (and its emotion comment) once the user's
  /// pick stops changing — the package streams a value per cascade step, so
  /// the card debounces and only emits the final one.
  final RatingChangedCallback? onRatingChanged;

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard>
    with SingleTickerProviderStateMixin {
  /// Drives the back-and-forth loading fill (0→1 fills from [_from] to [_to],
  /// 1→0 empties back), running only while a request is in flight.
  late final AnimationController _controller = AnimationController(vsync: this);

  /// The star the user picked and is now awaiting a response for; the loading
  /// fill animates from the committed [RatingCard.rating] up to this value.
  late int _pendingRating = widget.rating;

  /// Endpoints of the loading fill: [_from] is the committed value when the
  /// request started, [_to] the picked value being confirmed.
  int _from = 0;
  int _to = 0;

  /// Bumped to remount the (uncontrolled) [AnimatedRatingBar] so it re-seeds
  /// from the committed value — used to commit on success and revert on error.
  int _barGeneration = 0;

  Timer? _debounce;

  @override
  void didUpdateWidget(covariant RatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isLoading && widget.isLoading) {
      // A request just started: oscillate the fill between the value at rest
      // and the picked one until it settles.
      _debounce?.cancel();
      _from = widget.rating;
      _to = _pendingRating;
      final int distance = (_to - _from).abs().clamp(1, 5);
      _controller
        ..duration = Duration(milliseconds: 150 * distance)
        ..reset()
        ..repeat(reverse: true);
    } else if (oldWidget.isLoading && !widget.isLoading) {
      // The request settled: stop animating and remount the interactive bar so
      // it re-seeds from the committed value — the picked star on success, the
      // previous star on error.
      _controller.stop();
      _barGeneration++;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// The package streams a value per animation step (and once on mount); the
  /// card debounces and reports only the settled value — and only when it
  /// actually differs from the committed one (dropping the mount echo/no-ops).
  void _onBarChanged(int rating) {
    if (!mounted || rating == widget.rating) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted || rating == widget.rating) return;
      _pendingRating = rating;
      final ({String labelKey, String emoji}) emotion =
          _emotionForRating(rating);
      widget.onRatingChanged?.call(
        rating,
        '${emotion.labelKey.tr()} ${emotion.emoji}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    // The emotion pill tracks the committed value only, so its text stays put
    // through the whole request and changes solely when the parent commits.
    final ({String labelKey, String emoji}) emotion =
        _emotionForRating(widget.rating);

    final Widget emptyStar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Assets.media.images.svg.orderStarRate.svg(
        width: 20,
        colorFilter: ColorFilter.mode(
          colors.neutral400.withValues(alpha: 0.3),
          BlendMode.srcIn,
        ),
      ),
    );
    final Widget fullStar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Assets.media.images.svg.orderStarRate.svg(
        width: 20,
        colorFilter: ColorFilter.mode(colors.surface, BlendMode.srcIn),
      ),
    );

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

          // Emotion pill: emoji + label reflecting the committed star value,
          // swapped smoothly whenever that value changes.
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

          // While a request is in flight the interactive bar is swapped for a
          // non-interactive fill that oscillates between the old and picked
          // value; otherwise the tappable bar, remounted to re-seed on settle.
          if (widget.isLoading)
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                final double t = Curves.easeInOut.transform(_controller.value);
                final int fill = (_from + (_to - _from) * t).round();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    5,
                    (int i) => i < fill ? fullStar : emptyStar,
                  ),
                );
              },
            )
          else
            AnimatedRatingBar(
              key: ValueKey<int>(_barGeneration),
              animationType: ARBAnimationType.bounce,
              emptyWidget: emptyStar,
              fullWidget: fullStar,
              initialValue: widget.rating,
              onRatingChanged: _onBarChanged,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
        ],
      ),
    );
  }
}
