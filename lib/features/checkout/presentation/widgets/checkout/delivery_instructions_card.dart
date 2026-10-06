import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/focus_ring.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Inline editor for the per-order delivery instructions ("directions to the
/// driver"). The typed text is submitted with the order as `delivery_instructions`;
/// the parent owns the [controller] so it can read that value on confirm.
///
/// The field auto-grows: it starts one line tall and expands the card as the
/// text wraps onto more lines, up to [maxLines] before it starts scrolling.
class DeliveryInstructionsCard extends StatelessWidget {
  const DeliveryInstructionsCard({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return FocusRing(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              LangKeys.deliveryInstructionsKey.tr(),
              style: AppTextStyles.style16Medium.copyWith(
                color: colors.tertiaryContainer,
              ),
            ),
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: AppTextStyles.style14Regular.copyWith(color: colors.black),
              cursorColor: colors.tertiaryContainer,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: LangKeys.addInstructionsHintKey.tr(),
                hintStyle: AppTextStyles.style14Regular.copyWith(
                  color: colors.neutral500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
