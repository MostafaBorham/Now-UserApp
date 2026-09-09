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
    // The reply (or typing dots) comes first and the "now" avatar sits after
    // it, and the whole group hugs the end of the row. No forced direction: the
    // row follows the app locale, so the group pins to the tile's end on each
    // side — right in English, left in Arabic — with the avatar last and the
    // answer always glued to it.
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
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
                ? Align(
                    key: const ValueKey<bool>(true),
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.white,
                        // Tail corner (the tight radius) sits at the bottom on
                        // the avatar's side, so it flips with the language too.
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(12),
                          topEnd: Radius.circular(12),
                          bottomStart: Radius.circular(12),
                          bottomEnd: Radius.circular(4),
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
                      alignment: AlignmentDirectional.centerEnd,
                      child: TypingDotsIndicator(
                        idleColor: context.colors.neutral200,
                        activeColor: context.colors.neutral400,
                      ),
                    ),
                  ),
          ),
        ),
        // "now" support avatar, pinned to the end after the answer.
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // #F4F4F4 in Figma; reuses the near-identical #F5F5F5 token.
            color: context.colors.onPrimaryContainer,
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
      ],
    );
  }
}
