import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/focus_ring.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/input_direction.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_context_menu.dart';

/// Inline editor for the per-order delivery instructions ("directions to the
/// driver"). The typed text is submitted with the order as `delivery_instructions`;
/// the parent owns the [controller] so it can read that value on confirm.
///
/// The field starts three lines tall on its own white box, so it reads as a
/// place to write (BUG-043), and grows to five lines before it scrolls. It
/// takes at most [maxLength] characters and counts them underneath.
class DeliveryInstructionsCard extends StatelessWidget {
  /// The product's limit; the backend itself accepts up to 500.
  static const int maxLength = 250;

  const DeliveryInstructionsCard({super.key, required this.controller});

  final TextEditingController controller;

  // The card's FocusRing already marks focus, so the box itself never changes.
  static const OutlineInputBorder _box = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide.none,
  );

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
            InputDirectionBuilder(
              controller: controller,
              builder: (BuildContext context, TextDirection? typedDirection) =>
                  TextField(
                    contextMenuBuilder: appContextMenuBuilder,
                    controller: controller,
                    maxLength: maxLength,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textDirection: typedDirection,
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.black,
                    ),
                    cursorColor: colors.tertiaryContainer,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: colors.white,
                      contentPadding: const EdgeInsets.all(12),
                      border: _box,
                      enabledBorder: _box,
                      focusedBorder: _box,
                      hintText: LangKeys.addInstructionsHintKey.tr(),
                      hintStyle: AppTextStyles.style14Regular.copyWith(
                        color: colors.neutral500,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
