import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

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
                          'Special Offers',
                          style: TextStyle(
                            fontSize: con.maxWidth * 0.05,
                            color: colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: con.maxWidth * 0.4,
                          child: const _AutoScrollOffersList(itemCount: 30),
                        ),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 3,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadiusGeometry.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: colors.black.withValues(alpha: 0.25),
                            offset: Offset.zero,
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
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
  static const Duration _dwell = Duration(seconds: 4);
  static const Duration _step = Duration(milliseconds: 600);

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

    final double target = position.pixels >= max - 1.0
        ? 0.0
        : (position.pixels + position.viewportDimension).clamp(0.0, max);

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
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(
                  'https://as1.ftcdn.net/jpg/02/29/54/06/1000_F_229540688_nriN1k76uBt2lHMU9dMV2DbbXWGYPUj2.jpg',
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      separatorBuilder: (context, index) => 12.wSpace,
      itemCount: widget.itemCount,
    );
  }
}
