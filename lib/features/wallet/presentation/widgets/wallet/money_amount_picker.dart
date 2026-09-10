import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/formatters/double_formatter.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price/new_price_widget.dart';

class MoneyAmountPicker extends StatefulWidget {
  const MoneyAmountPicker({
    super.key,
    this.maxAmount,
    this.options,
    this.onAmountChanged,
    this.onOtherSelected,
  });

  /// Falls back to [_defaultMaxAmount] when the wallet doesn't supply a limit.
  final double? maxAmount;

  /// The suggested amount chips. When null/empty no chips are shown — only the
  /// "Other" selector remains, letting the user type a custom amount.
  final List<String>? options;

  final ValueChanged<String?>? onAmountChanged;
  final VoidCallback? onOtherSelected;

  static const double _defaultMaxAmount = 5000;

  @override
  State<MoneyAmountPicker> createState() => _MoneyAmountPickerState();
}

class _MoneyAmountPickerState extends State<MoneyAmountPicker> {
  String? selectedValue;
  final TextEditingController amountController = TextEditingController();
  bool isOtherSelected = false;

  /// True when the custom amount is typed above the allowed [_maxAmount].
  bool exceedsMax = false;

  List<String> get _options => widget.options ?? const <String>[];

  double get _maxAmount =>
      widget.maxAmount ?? MoneyAmountPicker._defaultMaxAmount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // With no suggested chips, start on the "Other" selector so the custom
      // amount field is the immediate (and only) way to enter an amount.
      if (_options.isEmpty) {
        setState(() => isOtherSelected = true);
        widget.onOtherSelected?.call();
        return;
      }
      _updateSelectedValue(_options.first);
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  /// A suggested chip is always within the limit, so any error clears here.
  void _updateSelectedValue(String newValue) {
    selectedValue = newValue;
    exceedsMax = false;
    widget.onAmountChanged?.call(selectedValue);
    setState(() {});
  }

  /// Validates the typed custom amount on every keystroke. When it exceeds
  /// [_maxAmount] the field goes into an error state and `null` is reported so
  /// the parent's Continue button stays disabled.
  void _applyCustomAmount(String value) {
    final double? parsed = double.tryParse(value);
    exceedsMax = parsed != null && parsed > _maxAmount;
    selectedValue = value;
    widget.onAmountChanged?.call((value.isEmpty || exceedsMax) ? null : value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pins the section to full width so its position/alignment never
        // shifts when the custom-amount field appears or disappears below.
        const SizedBox(width: double.infinity),
        Text(
          LangKeys.topUpAmountKey.tr(),
          style: AppTextStyles.style14Medium.copyWith(
            color: colors.black,
          ),
        ),
        10.hSpace,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          children: [
            ..._options.map((item) {
              final bool isSelected =
                  (!isOtherSelected && selectedValue == item);

              return GestureDetector(
                onTap: () {
                  isOtherSelected = false;
                  _updateSelectedValue(item);
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
                    price: item,
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
                    color: isOtherSelected
                        ? colors.white
                        : colors.black,
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
            children: [
              ...previousChildren,
              ?currentChild,
            ],
          ),
          child: isOtherSelected
              ? Column(
                  key: const ValueKey('custom_amount_field'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.neutral500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: exceedsMax
                              ? colors.error
                              : colors.primary500Main,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.style14Regular.copyWith(
                          color: exceedsMax ? colors.error : colors.black,
                        ),
                        onChanged: (newValue) {
                          _applyCustomAmount(newValue);
                        },
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
                    Row(
                      spacing: 6,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          LangKeys.maximumKey.tr(),
                          style: AppTextStyles.style14Regular.copyWith(
                            color: exceedsMax ? colors.error : colors.neutral500,
                          ),
                        ),
                        NewPriceWidget(
                          color: exceedsMax ? colors.error : colors.black,
                          price: formatDouble(_maxAmount).toString(),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
