import 'dart:math';
import 'package:flutter/material.dart';

class SpoolCarouselSlider extends StatefulWidget {
  const SpoolCarouselSlider({super.key});

  @override
  State<SpoolCarouselSlider> createState() => _SpoolCarouselSliderState();
}

class _SpoolCarouselSliderState extends State<SpoolCarouselSlider> {
  final PageController controller =
  PageController(viewportFraction: .25);

  double page = 0;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      setState(() {
        page = controller.page ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const radius = 180.0;

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 20,
            child: Text(
              'عروض',
              style: TextStyle(
                fontSize: 32,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...List.generate(
            8,
                (index) {
              final diff = index - page;

              final angle = diff * .45;

              final x = radius * sin(angle);
              final y = radius * cos(angle);

              final scale =
              (1 - (diff.abs() * .15)).clamp(.7, 1.2);

              return Transform.translate(
                offset: Offset(
                  x,
                  y - radius,
                ),
                child: Transform.scale(
                  scale: scale,
                  child: CircleAvatar(
                    radius: 32,
                    child: Text('$index'),
                  ),
                ),
              );
            },
          ),

          PageView.builder(
            controller: controller,
            itemCount: 8,
            itemBuilder: (_, _) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}