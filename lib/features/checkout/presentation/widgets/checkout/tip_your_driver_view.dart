import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/counters/full_width_counter_view.dart';

class TipYourDriverView extends StatefulWidget {
  const TipYourDriverView({super.key, this.initialTip, this.onTipChanged});





  final double? initialTip;





  final ValueChanged<double>? onTipChanged;

  @override
  State<TipYourDriverView> createState() => _TipYourDriverViewState();
}

class _TipYourDriverViewState extends State<TipYourDriverView> {


  static const int _otherTipInitialValue = 15;

  static const List<String> _presetTips = <String>['2', '5', '7', '10'];

  late final List<String> _tips = <String>[
    ..._presetTips,
    LangKeys.otherKey.tr(),
  ];



  late int? _selectedIndex = _indexForInitialTip(widget.initialTip);



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

    return _tips.length - 1;
  }

  @override
  void initState() {
    super.initState();
    final double? initial = widget.initialTip;
    if (initial == null || initial <= 0) return;


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onTipChanged?.call(initial);
    });
  }

  void _onTipSelected(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onPrimaryContainer,
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



          Row(
            spacing: 8,
            children: <Widget>[
              for (int index = 0; index < _presetTips.length; index++)
                _TipPill(
                  label: _presetTips[index],
                  isSelected: index == _selectedIndex,
                  onTap: () => _onTipSelected(index),
                ),
              Expanded(
                child: _TipPill(
                  label: _tips.last,
                  isSelected: _selectedIndex == _tips.length - 1,
                  isWide: true,
                  onTap: () => _onTipSelected(_tips.length - 1),
                ),
              ),
            ],
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




class _TipPill extends StatelessWidget {
  const _TipPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isWide = false,
  });

  final String label;
  final bool isSelected;
  final bool isWide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 16 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary500Main : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: SizedBox(
          width: isWide ? null : 20,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.style14Regular.copyWith(
              color: isSelected ? colors.white : colors.neutral500,
            ),
          ),
        ),
      ),
    );
  }
}
