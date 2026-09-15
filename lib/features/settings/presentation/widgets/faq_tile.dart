import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/faq_answer_chat.dart';
import 'package:nowdelivery_user_app/features/settings/presentation/widgets/faq_card_shell.dart';



class FaqTile extends StatelessWidget {
  const FaqTile({
    super.key,
    required this.question,
    required this.answer,
    required this.expanded,
    this.onTap,
  });

  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FaqCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: context.colors.tertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: context.colors.neutral500,
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            FaqAnswerChat(answer: answer),
          ],
        ],
      ),
    );
  }
}
