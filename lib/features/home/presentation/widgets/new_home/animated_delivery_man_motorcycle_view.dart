import 'dart:async';

import 'package:flutter/material.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';


class AnimatedDeliveryManMotorcycleView extends StatefulWidget {
  const AnimatedDeliveryManMotorcycleView({super.key, this.width});

  final double? width;

  @override
  State<AnimatedDeliveryManMotorcycleView> createState() =>
      _AnimatedDeliveryManMotorcycleViewState();
}

class _AnimatedDeliveryManMotorcycleViewState
    extends State<AnimatedDeliveryManMotorcycleView> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,con) {
        return SizedBox(
          height: con.maxWidth*0.2,
          child: Stack(
            children: [
              RepaintBoundary(
                child: ReverseWidget(
                  applyReverse: !context.isRTL,
                  child: AnimatedSvgPicture.asset(
                    Assets.media.images.svg.deliveryManMotocycle.path,
                    fit: BoxFit.contain,
                    playbackRate: 1,
                    autoPlay: true,
                    placeholderBuilder: (BuildContext context) => SizedBox.shrink(),
                  ),
                ),
              ),
              RepaintBoundary(
                child: AnimatedSvgPicture.asset(
                  context.isRTL? Assets.media.images.svg.quickDeliverArabic.path : Assets.media.images.svg.englishAnimatedQuickDelivery.path,
                  fit: BoxFit.contain,
                  playbackRate: 1,
                  autoPlay: true,
                  placeholderBuilder: (BuildContext context) => SizedBox.shrink(),
                ),
              )
            ],
          ),
        );
      }
    );
  }
}
