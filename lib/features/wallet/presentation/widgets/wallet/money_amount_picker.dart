import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/price_with_currency.dart';

class MoneyAmountPicker extends StatefulWidget {
  const MoneyAmountPicker({
    super.key,
    this.maxAmount = 5000,
    this.options = const ['300', '400', '500', '1000'],
    this.onAmountChanged,
  });

  final int maxAmount;
  final List<String> options;

  final ValueChanged<String?>? onAmountChanged;

  @override
  State<MoneyAmountPicker> createState() => _MoneyAmountPickerState();
}

class _MoneyAmountPickerState extends State<MoneyAmountPicker> {
  String? selectedValue;
  final TextEditingController amountController = TextEditingController();
  bool isOtherSelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedValue(widget.options.last);
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void _updateSelectedValue(String newValue) {
    selectedValue = newValue;
    widget.onAmountChanged?.call(selectedValue);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          LangKeys.topUpAmountKey.tr(),
          style: AppTextStyles.style14Medium.copyWith(
            color: colors.onSecondary,
          ),
        ),
        10.hSpace,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: widget.options.map((item) {
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
                          ? colors.primary
                          : colors.onSurface.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.brCircular20,
                    ),
                    child: Row(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [  Assets.media.images.svg.realSaudiCurrency.svg(
                        width: 10,
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSecondary,
                      ),
                        Text(
                          item,
                          style: AppTextStyles.style12Regular.copyWith(
                            color: isSelected
                                ? colors.onPrimary
                                : colors.onSecondary,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            GestureDetector(
              onTap: () {
                isOtherSelected = true;
                _updateSelectedValue(amountController.text);
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
                      ? colors.primary
                      : colors.onSurface.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.brCircular20,
                ),
                child: Text(
                  LangKeys.otherKey.tr(),
                  style: AppTextStyles.style12Regular.copyWith(
                    color: isOtherSelected
                        ? colors.onPrimary
                        : colors.onSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        18.hSpace,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isOtherSelected
              ? Column(
                  key: const ValueKey('custom_amount_field'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: colors.primary, width: 1),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (newValue) {
                          _updateSelectedValue(newValue);
                        },
                        decoration: InputDecoration(
                          hintText: LangKeys.enterAmountKey.tr(),
                          hintStyle: AppTextStyles.style14Regular.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.3),
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
                            color: colors.onSurface,
                          ),
                        ),
                        PriceWithCurrency(
                          color: colors.onSecondary,
                          price: widget.maxAmount.toString(),
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
