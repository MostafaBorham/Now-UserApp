import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/counters/full_width_counter_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/selectors/app_selector.dart';

class TipYourDriverView extends StatefulWidget {
  const TipYourDriverView({super.key, this.initialTip, this.onTipChanged});

  /// The tip to preselect. When it matches one of the preset amounts the
  /// matching pill is highlighted; any other non-null value is treated as a
  /// custom amount and lights up "Other" with the counter opened on it.
  /// `null` (or `0`) preselects nothing, matching the "no tip" default.
  final double? initialTip;

  /// Reports the tip the user picked — a preset amount, or the counter value
  /// while "Other" is selected. Also fired once after the first frame with
  /// [initialTip] when it's non-null, so the parent's stored value stays in
  /// sync with the visually preselected pill.
  final ValueChanged<double>? onTipChanged;

  @override
  State<TipYourDriverView> createState() => _TipYourDriverViewState();
}

class _TipYourDriverViewState extends State<TipYourDriverView> {
  /// The amount the counter starts at when "Other" is selected without an
  /// initial value being carried in.
  static const int _otherTipInitialValue = 13;

  static const List<String> _presetTips = <String>['2', '5', '8', '10', '12'];

  late final List<String> _tips = <String>[
    ..._presetTips,
    LangKeys.otherKey.tr(),
  ];

  /// Which pill is highlighted, resolved from [TipYourDriverView.initialTip].
  /// `null` = nothing selected (no tip).
  late int? _selectedIndex = _indexForInitialTip(widget.initialTip);

  /// The counter's starting value when "Other" is preselected — either the
  /// carried-in custom amount or the built-in default.
  late final int _otherCounterInitial = _isCustomInitial(widget.initialTip)
      ? widget.initialTip!.round()
      : _otherTipInitialValue;

  late bool showTipOtherCounterView = _selectedIndex == _tips.length - 1;

  static int _presetIndex(double? tip) {
    if (tip == null) return -1;
    return _presetTips.indexWhere(
      (String preset) => double.parse(preset) == tip,
    );
  }

  static bool _isCustomInitial(double? tip) =>
      tip != null && tip > 0 && _presetIndex(tip) < 0;

  int? _indexForInitialTip(double? tip) {
    if (tip == null || tip <= 0) return null;
    final int preset = _presetIndex(tip);
    if (preset >= 0) return preset;
    // Any other non-null amount is a custom tip → the "Other" pill.
    return _tips.length - 1;
  }

  @override
  void initState() {
    super.initState();
    final double? initial = widget.initialTip;
    if (initial == null || initial <= 0) return;
    // Fire after the first frame so the parent's setState (if any) doesn't
    // race with this widget's first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onTipChanged?.call(initial);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.neutral500.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            LangKeys.tipYourDriverKey.tr(),
            style: AppTextStyles.style16Medium.copyWith(
              color: colors.tertiaryContainer,
            ),
          ),
          5.hSpace,
          AppSelector(
            items: _tips,
            initialIndex: _selectedIndex,
            onChanged: (int index) {
              final bool isOtherSelected = index == _tips.length - 1;

              setState(() {
                _selectedIndex = index;
                showTipOtherCounterView = isOtherSelected;
              });

              widget.onTipChanged?.call(
                isOtherSelected
                    ? _otherCounterInitial.toDouble()
                    : double.tryParse(_tips[index]) ?? 0,
              );
            },
            labelColor: colors.neutral500,
            selectedColor: colors.tertiaryContainer,
            radius: 999,
            borderColor: Colors.transparent,
            unselectedColor: Colors.transparent,
          ),
          if (showTipOtherCounterView)
            FullWidthCounterView(
              initialValue: _otherCounterInitial,
              onValueChanged: (int value) =>
                  widget.onTipChanged?.call(value.toDouble()),
            ),
        ],
      ),
    );
  }
}
