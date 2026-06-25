import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowdelivery_user_app/view/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/view/responsive/spacing_extension.dart';
import 'package:nowdelivery_user_app/view/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/view/styles/text_styles.dart';
import 'package:nowdelivery_user_app/view/widgets/shared/price_with_currency.dart';

class MoneyAmountPicker extends StatefulWidget {
  const MoneyAmountPicker({
    super.key,
    this.maxAmount = 5000,
    this.options = const ['300', '400', '500', '1000'],
    this.onAmountChanged,
  });

  final int maxAmount;
  final List<String> options;

  /// يرجع المبلغ المختار النهائي:
  /// - لو اختار مبلغ جاهز => "300" مثلا
  /// - لو اختار "أخرى" وكتب قيمة => القيمة المكتوبة
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
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Top-up Amount',
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
                        width: 10.w,
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
                  'Other',
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
                          hintText: 'Enter amount',
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
                          'Maximum',
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
