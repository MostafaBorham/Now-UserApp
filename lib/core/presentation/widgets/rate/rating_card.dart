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




typedef RatingChangedCallback = void Function(int rating, String comment);




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
    this.rating = 1,
    this.isLoading = false,
    this.onRatingChanged,
  });

  final String title;


  final int rating;



  final bool isLoading;




  final RatingChangedCallback? onRatingChanged;

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard>
    with SingleTickerProviderStateMixin {









  late final AnimationController _controller;



  late int _pendingRating = widget.rating;



  int _from = 0;
  int _to = 0;



  int _barGeneration = 0;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant RatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isLoading && widget.isLoading) {


      _debounce?.cancel();
      _from = widget.rating;
      _to = _pendingRating;
      final int distance = (_to - _from).abs().clamp(1, 5);
      _controller
        ..duration = Duration(milliseconds: 150 * distance)
        ..reset()
        ..repeat(reverse: true);
    } else if (oldWidget.isLoading && !widget.isLoading) {



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
