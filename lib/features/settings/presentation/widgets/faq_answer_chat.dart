import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// The answer under an expanded FAQ, drawn as a chat reply from the app: the
/// server's HTML flattened to text in a bubble, beside the logo.
class FaqAnswerChat extends StatelessWidget {
  const FaqAnswerChat({super.key, required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Flexible(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                html_parser.parse(answer).body?.text.trim() ?? '',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: context.colors.tertiaryContainer,
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
              BoxShadow(color: Color(0x0F000000), blurRadius: 16.67),
            ],
          ),
          child: Assets.media.images.svg.logoHorizontal.svg(width: 26),
        ),
      ],
    );
  }
}
