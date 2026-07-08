import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';

class ApplyDiscountCodeView extends StatefulWidget {
  const ApplyDiscountCodeView({
    super.key,
    this.hintText = 'Discount Code',
    this.onApply,
  });

  final String hintText;
  final ValueChanged<String>? onApply;

  @override
  State<ApplyDiscountCodeView> createState() =>
      _ApplyDiscountCodeViewState();
}

class _ApplyDiscountCodeViewState
    extends State<ApplyDiscountCodeView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.onPrimaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: TextField(
                controller: _controller,
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.onSecondary,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: AppTextStyles.style14Regular.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => widget.onApply?.call(_controller.text),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: colors.onSecondaryFixedVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Apply',
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
