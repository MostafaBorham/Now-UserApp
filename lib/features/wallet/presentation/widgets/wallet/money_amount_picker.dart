import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

/// Picks a top-up amount, either from the server's suggested chips or as a
/// typed custom amount.
///
/// Amounts are reported in whole **halalas**, never as display text: the chip
/// labels are rounded for legibility, so reporting the label would charge what
/// the label says rather than what the server offered.
class MoneyAmountPicker extends StatefulWidget {
  const MoneyAmountPicker({
    super.key,
    required this.minAmountHalalas,
    required this.maxAmountHalalas,
    this.options,
    this.onAmountChanged,
    this.onOtherSelected,
  });

  /// The server's funding limits, in halalas. Both come from the wallet
  /// response — there is no client-side fallback, because inventing a limit
  /// only produces amounts the server then rejects.
  final int minAmountHalalas;
  final int maxAmountHalalas;

  /// The suggested amount chips, in SAR as the server sends them. When
  /// null/empty no chips are shown — only the "Other" selector remains, letting
  /// the user type a custom amount.
  final List<double>? options;

  /// Reports the selected amount in whole halalas, or `null` while the current
  /// input is not a submittable amount.
  final ValueChanged<int?>? onAmountChanged;
  final VoidCallback? onOtherSelected;

  @override
  State<MoneyAmountPicker> createState() => _MoneyAmountPickerState();
}

class _MoneyAmountPickerState extends State<MoneyAmountPicker> {
  /// The chip currently selected, in halalas. Null while "Other" is active.
  int? selectedHalalas;
  final TextEditingController amountController = TextEditingController();
  bool isOtherSelected = false;

  /// True when the custom amount is above the server's maximum.
  bool exceedsMax = false;

  /// True when the custom amount is below the server's minimum.
  bool belowMin = false;

  /// True when the field holds text that isn't a valid top-up amount at all — a
  /// stray comma, a minus sign, or more than two decimal places. Kept separate
  /// from [exceedsMax] / [belowMin] so each hint only reddens for its own limit.
  bool hasInvalidAmount = false;

  List<double> get _options => widget.options ?? const <double>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // With no suggested chips, start on the "Other" selector so the custom
      // amount field is the immediate (and only) way to enter an amount.
      if (_options.isEmpty) {
        setState(() => isOtherSelected = true);
        widget.onOtherSelected?.call();
        return;
      }
      _selectSuggested(_options.first);
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  /// A suggested chip comes from the server already within its own limits, so
  /// any error clears here.
  void _selectSuggested(double amountSar) {
    selectedHalalas = sarDoubleToHalalas(amountSar);
    exceedsMax = false;
    belowMin = false;
    hasInvalidAmount = false;
    widget.onAmountChanged?.call(selectedHalalas);
    setState(() {});
  }

  /// Validates the typed custom amount on every keystroke. Valid means a plain
  /// decimal of at most two places, within the server's minimum and maximum.
  /// On anything else `null` is reported so the parent's button stays disabled.
  void _applyCustomAmount(String value) {
    final int? halalas = parseSarToHalalas(value);

    exceedsMax = halalas != null && halalas > widget.maxAmountHalalas;
    belowMin = halalas != null && halalas < widget.minAmountHalalas;
    final bool isValid = halalas != null && !exceedsMax && !belowMin;
    hasInvalidAmount = value.trim().isNotEmpty && halalas == null;

    selectedHalalas = isValid ? halalas : null;
    widget.onAmountChanged?.call(selectedHalalas);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool hasFieldError = exceedsMax || belowMin || hasInvalidAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pins the section to full width so its position/alignment never
        // shifts when the custom-amount field appears or disappears below.
        const SizedBox(width: double.infinity),
        Text(
          LangKeys.topUpAmountKey.tr(),
          style: AppTextStyles.style14Medium.copyWith(color: colors.black),
        ),
        10.hSpace,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          children: [
            ..._options.map((double item) {
              final bool isSelected =
                  !isOtherSelected &&
                  selectedHalalas == sarDoubleToHalalas(item);

              return GestureDetector(
                onTap: () {
                  isOtherSelected = false;
                  _selectSuggested(item);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary500Main
                        : colors.neutral500.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.brCircular20,
                  ),
                  child: NewPriceWidget(
                    color: isSelected ? colors.white : colors.black,
                    price: formatMoney(item),
                    size: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () {
                isOtherSelected = true;
                _applyCustomAmount(amountController.text);
                widget.onOtherSelected?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isOtherSelected
                      ? colors.primary500Main
                      : colors.neutral500.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.brCircular20,
                ),
                child: Text(
                  LangKeys.otherKey.tr(),
                  style: AppTextStyles.style12Regular.copyWith(
                    color: isOtherSelected ? colors.white : colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        18.hSpace,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: AlignmentDirectional.topStart,
            children: [...previousChildren, ?currentChild],
          ),
          child: isOtherSelected
              ? Column(
                  key: const ValueKey('custom_amount_field'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.neutral500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: hasFieldError
                              ? colors.error
                              : colors.primary500Main,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: amountController,
                        // Decimal, because the server's amounts are two-place
                        // decimals — an integer pad would make a valid amount
                        // untypeable.
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: AppTextStyles.style14Regular.copyWith(
                          color: hasFieldError ? colors.error : colors.black,
                        ),
                        onChanged: _applyCustomAmount,
                        decoration: InputDecoration(
                          hintText: LangKeys.enterAmountKey.tr(),
                          hintStyle: AppTextStyles.style14Regular.copyWith(
                            color: colors.neutral500.withValues(alpha: 0.3),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Both limits are shown, and each reddens only for its own
                    // breach, so the customer can see what they have to hit
                    // rather than discovering it through a server rejection.
                    _LimitHint(
                      label: LangKeys.minimumLimitKey.tr(),
                      amountHalalas: widget.minAmountHalalas,
                      isBreached: belowMin,
                    ),
                    const SizedBox(height: 4),
                    _LimitHint(
                      label: LangKeys.maximumKey.tr(),
                      amountHalalas: widget.maxAmountHalalas,
                      isBreached: exceedsMax,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// One `minimum` / `maximum` line under the custom amount field, reddening when
/// that particular limit is the one being broken.
class _LimitHint extends StatelessWidget {
  const _LimitHint({
    required this.label,
    required this.amountHalalas,
    required this.isBreached,
  });

  final String label;
  final int amountHalalas;
  final bool isBreached;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Row(
      spacing: 6,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.style14Regular.copyWith(
            color: isBreached ? colors.error : colors.neutral500,
          ),
        ),
        NewPriceWidget(
          color: isBreached ? colors.error : colors.black,
          price: formatMoney(amountHalalas / halalasPerSar),
          size: 18,
        ),
      ],
    );
  }
}
