import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Three dots rippling in a continuous wave — a chat "typing…" indicator.
///
/// Each dot eases between [idleColor] and [activeColor] with a subtle scale bump
/// on a staggered phase, so the highlight travels across the row. The animation
/// is self-contained (its controller repeats for the widget's lifetime) and
/// wrapped in a [RepaintBoundary] so it never repaints its neighbours.
class TypingDotsIndicator extends StatefulWidget {
  const TypingDotsIndicator({
    super.key,
    required this.idleColor,
    required this.activeColor,
    this.dotSize = 8,
    this.spacing = 4,
    this.count = 3,
  });

  final Color idleColor;
  final Color activeColor;
  final double dotSize;
  final double spacing;
  final int count;

  @override
  State<TypingDotsIndicator> createState() => _TypingDotsIndicatorState();
}

class _TypingDotsIndicatorState extends State<TypingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            // The dots are symmetric, so pin the row to LTR: otherwise in RTL
            // the reversed layout drops the physical `right` gaps on the wrong
            // side and two dots end up touching.
            textDirection: TextDirection.ltr,
            children: List.generate(widget.count, (index) {
              // Stagger each dot along the cycle so the bounce ripples across.
              final double phase = (_controller.value + index * 0.18) % 1.0;
              // Smooth 0 → 1 → 0 bump over one cycle.
              final double t = (math.sin(phase * 2 * math.pi) + 1) / 2;
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.count - 1 ? 0 : widget.spacing,
                ),
                // Bounce vertically instead of scaling, so each dot keeps its
                // footprint and the gaps between the three stay equal.
                child: Transform.translate(
                  offset: Offset(0, -t * 3),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        widget.idleColor,
                        widget.activeColor,
                        t,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
