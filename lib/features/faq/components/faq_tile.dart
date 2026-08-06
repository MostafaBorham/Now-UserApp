import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

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
      color: expanded
          ? context.colors.primary100
          : context.colors.onTertiaryContainer,
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
                const SizedBox(height: 10),
                Text(
                  item.answer,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: context.colors.neutral500,
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
