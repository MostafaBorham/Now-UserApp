import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';

class HomeOffersSectionView extends StatelessWidget {
  const HomeOffersSectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return LayoutBuilder(
      builder: (context, con) {
        return SizedBox(
          width: con.maxWidth,
          child: Stack(
            children: [
              Positioned(
                bottom: 12,
                height: con.maxWidth * 0.6,
                width: con.maxWidth,
                child: Assets.media.images.svg.homeOffersBackground.svg(
                  fit: BoxFit.fill,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 32,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          'عروض مميزة',
                          style: TextStyle(
                            fontSize: con.maxWidth * 0.05,
                            color: colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: con.maxWidth * 0.4,
                          child: const _AutoScrollOffersList(itemCount: 10),
                        ),
                      ],
                    ),
                  ),
                  const _AnimatedOffersBanner(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


class _AutoScrollOffersList extends StatefulWidget {
  const _AutoScrollOffersList({required this.itemCount});

  final int itemCount;

  @override
  State<_AutoScrollOffersList> createState() => _AutoScrollOffersListState();
}

class _AutoScrollOffersListState extends State<_AutoScrollOffersList> {
  static const Duration _dwell = Duration(seconds: 3);
  static const Duration _step = Duration(milliseconds: 900);
  static const double _separator = 12;
  static const double _aspectRatio = 0.7;

  final ScrollController _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer.periodic(_dwell, (_) => _stepForward());
    });
  }

  void _stepForward() {
    if (!_controller.hasClients) return;
    final ScrollPosition position = _controller.position;
    final double max = position.maxScrollExtent;
    if (max <= 0) return;

    // Advance by exactly one card so each step hides the current first
    // visible item. The card width is derived from the list's height
    // (its cross-axis extent) and the card's aspect ratio.
    final double listHeight = context.size?.height ?? 0;
    if (listHeight <= 0) return;
    final double itemExtent = listHeight * _aspectRatio + _separator;

    final double target = position.pixels >= max - 1.0
        ? 0.0
        : (position.pixels + itemExtent).clamp(0.0, max);

    _controller.animateTo(target, duration: _step, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsetsDirectional.only(end: 10),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => RepaintBoundary(
        child: AspectRatio(
          aspectRatio: 0.7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: const AppCachedNetworkImage(
              imageUrl:
                  'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      separatorBuilder: (context, index) => 12.wSpace,
      itemCount: widget.itemCount,
    );
  }
}

/// Isolated so its loop never rebuilds the surrounding section.
///
/// Timeline (repeats forever): starts off-screen at the page's start (leading)
/// edge; [_initialDelay] after load it slides in, stays for [_visibleDwell],
/// then vanishes instantly (snaps off-side, no animation); after [_hiddenDwell]
/// it slides in again.
///
/// The [AnimationController] runs only during the ~600 ms slide itself and sits
/// idle through both dwells — a plain [Timer] wakes it — so it stays cheap. The
/// motion is a [SlideTransition] (a `Transform`, no `saveLayer`), wrapped in a
/// [RepaintBoundary] to keep its repaints local.
class _AnimatedOffersBanner extends StatefulWidget {
  const _AnimatedOffersBanner();

  @override
  State<_AnimatedOffersBanner> createState() => _AnimatedOffersBannerState();
}

class _AnimatedOffersBannerState extends State<_AnimatedOffersBanner>
    with SingleTickerProviderStateMixin {
  static const Duration _slide = Duration(milliseconds: 600);
  static const Duration _initialDelay = Duration(seconds: 2);
  static const Duration _visibleDwell = Duration(seconds: 6);
  static const Duration _hiddenDwell = Duration(seconds: 2);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _slide,
  );
  late Animation<Offset> _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
    // Stays hidden off-side; slides in for the first time after the delay.
    _timer = Timer(_initialDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Enter from the page's start (leading) side, direction-aware (RTL/LTR).
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    _offset = Tween<Offset>(
      begin: Offset(isRtl ? 1.15 : -1.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Fully visible -> hold, then vanish instantly (snap off-side, no anim).
      _timer = Timer(_visibleDwell, () {
        if (mounted) _controller.reset();
      });
    } else if (status == AnimationStatus.dismissed) {
      // Fully hidden -> wait, then slide in again. Loops forever.
      _timer = Timer(_hiddenDwell, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return RepaintBoundary(
      child: SlideTransition(
        position: _offset,
        child: AspectRatio(
          aspectRatio: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colors.black.withValues(alpha: 0.25),
                  offset: Offset.zero,
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const AppCachedNetworkImage(
              imageUrl:
                  'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
