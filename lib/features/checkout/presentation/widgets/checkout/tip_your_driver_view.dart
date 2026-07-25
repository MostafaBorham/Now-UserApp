import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/counters/full_width_counter_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class TipYourDriverView extends StatefulWidget {
  const TipYourDriverView({super.key, this.onTipChanged});

  /// Reports the tip the user picked — a preset amount, or the counter value
  /// while "Other" is selected. Not called until the user actually picks one,
  /// so the parent's own default stands for "no tip".
  final ValueChanged<double>? onTipChanged;

  @override
  State<TipYourDriverView> createState() => _TipYourDriverViewState();
}

class _TipYourDriverViewState extends State<TipYourDriverView> {
  /// The amount the counter starts at when "Other" is selected.
  static const int _otherTipInitialValue = 13;

  bool showTipOtherCounterView = false;
  @override
  Widget build(BuildContext context) {
    final List<String> tips = ['2', '5', '8','10', '12', LangKeys.otherKey.tr()];
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            'Tip your driver',
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          5.hSpace,
          AppSelector(
            items: tips,
            // Nothing is preselected: a highlighted amount the request would
            // not carry would misreport the tip the user is about to pay.
            initialIndex: null,
            onChanged: (index) {
              final bool isOtherSelected = index == tips.length - 1;

              setState(() => showTipOtherCounterView = isOtherSelected);

              widget.onTipChanged?.call(
                isOtherSelected
                    ? _otherTipInitialValue.toDouble()
                    : double.tryParse(tips[index]) ?? 0,
              );
            },
            labelColor: colors.onSurface,
            selectedColor: colors.tertiaryContainer,
            radius: 999,
            borderColor: Colors.transparent,
            unselectedColor: Colors.transparent,
          ),
          if (showTipOtherCounterView)
            FullWidthCounterView(
              initialValue: _otherTipInitialValue,
              onValueChanged: (int value) =>
                  widget.onTipChanged?.call(value.toDouble()),
            ),
        ],
      ),
    );
  }
}
