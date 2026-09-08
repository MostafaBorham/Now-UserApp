import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/typing_dots_indicator.dart';

/// The answer area of an expanded FAQ tile, staged as a support-chat reply:
/// the "now" avatar sits beside a typing indicator that, after [replyDelay],
/// gives way to the answer bubble — as if support has just replied.
class FaqAnswerChat extends StatefulWidget {
  const FaqAnswerChat({
    super.key,
    required this.answer,
    this.replyDelay = const Duration(seconds: 5),
  });

  final String answer;
  final Duration replyDelay;

  @override
  State<FaqAnswerChat> createState() => _FaqAnswerChatState();
}

class _FaqAnswerChatState extends State<FaqAnswerChat> {
  bool _replied = false;
  Timer? _replyTimer;

  @override
  void initState() {
    super.initState();
    _replyTimer = Timer(widget.replyDelay, () {
      if (mounted) setState(() => _replied = true);
    });
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Preserve the app's reading direction for the answer text, then lay the
    // row out left-to-right so the avatar pins to the tile's end (its left
    // edge in RTL) with the reply beside it — matching the design.
    final TextDirection textDirection = Directionality.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "now" support avatar.
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000), // black 6%
                  blurRadius: 16.67,
                ),
              ],
            ),
            child: Assets.media.images.svg.logoHorizontal.svg(width: 26),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
              child: _replied
                  ? Directionality(
                      key: const ValueKey<bool>(true),
                      textDirection: textDirection,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          widget.answer,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: context.colors.tertiaryContainer,
                          ),
                        ),
                      ),
                    )
                  // Waiting state: keeps the avatar's 40px row height so the dots
                  // sit centred beside it until the reply lands.
                  : SizedBox(
                      key: const ValueKey<bool>(false),
                      height: 40,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TypingDotsIndicator(
                          idleColor: context.colors.neutral200,
                          activeColor: context.colors.neutral400,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
