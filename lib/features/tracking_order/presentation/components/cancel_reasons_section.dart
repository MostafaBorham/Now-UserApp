import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/text_fields/app_description_field.dart';

enum CancelOrderReason {
  noLongerNeeded(LangKeys.cancelReasonNoLongerNeededKey),
  betterPrice(LangKeys.cancelReasonBetterPriceKey),
  orderedByMistake(LangKeys.cancelReasonOrderedByMistakeKey),
  changeItems(LangKeys.cancelReasonChangeItemsKey),
  other(LangKeys.otherKey);

  const CancelOrderReason(this.labelKey);

  final String labelKey;
}

class CancelReasonsSection extends StatefulWidget {
  const CancelReasonsSection({
    super.key,
    required this.selectedReason,
    required this.otherReasonController,
    required this.onReasonSelected,
  });

  final CancelOrderReason? selectedReason;
  final TextEditingController otherReasonController;
  final ValueChanged<CancelOrderReason> onReasonSelected;

  @override
  State<CancelReasonsSection> createState() => _CancelReasonsSectionState();
}

class _CancelReasonsSectionState extends State<CancelReasonsSection> {
  final GlobalKey _otherReasonFieldKey = GlobalKey();
  final FocusNode _otherReasonFocus = FocusNode();

  @override
  void dispose() {
    _otherReasonFocus.dispose();
    super.dispose();
  }

  void _selectReason(CancelOrderReason reason) {
    widget.onReasonSelected(reason);
    if (reason != CancelOrderReason.other) return;

    // The field is laid out on the frame after selecting Other.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BuildContext? fieldContext = _otherReasonFieldKey.currentContext;
      if (fieldContext == null) return;

      await Scrollable.ensureVisible(
        fieldContext,
        duration: MediaQuery.disableAnimationsOf(fieldContext)
            ? Duration.zero
            : const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      if (fieldContext.mounted) _otherReasonFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LangKeys.chooseCancelReasonKey.tr(),
            style: AppTextStyles.style14Bold.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              for (final CancelOrderReason reason in CancelOrderReason.values)
                _CancelReasonOption(
                  label: reason.labelKey.tr(),
                  isSelected: reason == widget.selectedReason,
                  onTap: () => _selectReason(reason),
                ),
              if (widget.selectedReason == CancelOrderReason.other)
                AppDescriptionField(
                  key: _otherReasonFieldKey,
                  hintTxt: LangKeys.cancelReasonOtherHintKey.tr(),
                  controller: widget.otherReasonController,
                  focusNode: _otherReasonFocus,
                  maxLength: 255,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelReasonOption extends StatelessWidget {
  const _CancelReasonOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final Color radioColor = isSelected
        ? colors.primary500Main
        : colors.outline;
    return Semantics(
      checked: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: isSelected
            ? colors.primary500Main.withValues(alpha: 0.1)
            : colors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? colors.primary500Main : colors.neutral200,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: radioColor, width: 1.5),
                  ),
                  child: isSelected
                      ? Icon(Icons.circle, size: 10, color: radioColor)
                      : null,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: isSelected
                        ? AppTextStyles.style14SemiBold.copyWith(
                            color: colors.primary500Main,
                          )
                        : AppTextStyles.style14Medium.copyWith(
                            color: colors.tertiaryContainer,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
