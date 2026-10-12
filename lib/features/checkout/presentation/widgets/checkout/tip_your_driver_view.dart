import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

/// The tip picker. Nothing is preselected — there is no tip until the customer
/// picks one — and tapping the selected pill again takes the tip back.
class TipYourDriverView extends StatefulWidget {
  const TipYourDriverView({super.key, this.onTipChanged});

  /// Reports the tip the user picked — a preset amount, the typed amount
  /// while "Other" is selected (`0` while empty), or `0` when the selection
  /// is taken back.
  final ValueChanged<double>? onTipChanged;

  @override
  State<TipYourDriverView> createState() => _TipYourDriverViewState();
}

class _TipYourDriverViewState extends State<TipYourDriverView> {
  /// The server refuses a larger `driver_tip` (`max:1000`), so the field
  /// never holds one.
  static const int _maxTip = 1000;

  static const List<String> _presetTips = <String>['2', '5', '7', '10'];

  /// Kept across a deselect, so picking "Other" again brings the amount back.
  final TextEditingController _otherTipController = TextEditingController();

  double get _otherTip => double.tryParse(_otherTipController.text) ?? 0;

  late final List<String> _tips = <String>[
    ..._presetTips,
    LangKeys.otherKey.tr(),
  ];

  /// Which pill is highlighted; `null` = no tip.
  int? _selectedIndex;

  bool get _isOtherSelected => _selectedIndex == _tips.length - 1;

  @override
  void dispose() {
    _otherTipController.dispose();
    super.dispose();
  }

  void _onTipSelected(int index) {
    setState(() => _selectedIndex = index == _selectedIndex ? null : index);

    final int? selected = _selectedIndex;
    widget.onTipChanged?.call(
      selected == null
          ? 0
          : _isOtherSelected
          ? _otherTip
          : double.parse(_tips[selected]),
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
          // A plain Row, not [AppSelector]: the design fixes the four presets to
          // an equal width and lets "Other" flex into whatever is left, which a
          // scrollable equal-treatment list can't express.
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
          if (_isOtherSelected)
            TextField(
              controller: _otherTipController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction(
                  (TextEditingValue old, TextEditingValue next) =>
                      (int.tryParse(next.text) ?? 0) <= _maxTip ? next : old,
                ),
              ],
              onChanged: (_) => widget.onTipChanged?.call(_otherTip),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: AppTextStyles.style14Regular.copyWith(
                color: colors.tertiaryContainer,
              ),
              cursorColor: colors.tertiaryContainer,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: LangKeys.enterAmountKey.tr(),
                hintStyle: AppTextStyles.style14Regular.copyWith(
                  color: colors.neutral500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: colors.neutral200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: colors.primary500Main),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One tip amount. Presets size their label to a fixed width so all four pills
/// come out equal regardless of digit count; [isWide] is the "Other" pill, which
/// the parent wraps in an [Expanded] to eat the rest of the row.
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
