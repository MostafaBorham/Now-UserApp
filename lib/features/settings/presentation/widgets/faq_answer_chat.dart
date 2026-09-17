import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/typing_dots_indicator.dart';




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

        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(

            color: context.colors.onPrimaryContainer,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
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
