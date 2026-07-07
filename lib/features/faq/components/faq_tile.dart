import 'package:flutter/material.dart';

import '../../settings/app_colors.dart';

/// A single FAQ question and its answer.
class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// An expandable FAQ card: the question with a chevron, and — when [expanded]
/// — the answer beneath. Tapping anywhere toggles it via [onTap].
class FaqTile extends StatelessWidget {
  const FaqTile({
    super.key,
    required this.item,
    required this.expanded,
    this.onTap,
  });

  final FaqItem item;
  final bool expanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: expanded ? AppColors.faqExpandedBg : AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 24,
                    color: AppColors.chevron,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 10),
                Text(
                  item.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.hintText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
