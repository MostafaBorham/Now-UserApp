import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';

class ApplyDiscountCodeView extends ConsumerStatefulWidget {
  const ApplyDiscountCodeView({
    super.key,
    this.hintText = 'Discount Code',
    this.vendorId,
    this.storeId,
  });

  final String hintText;

  /// The vendor this discount applies to (the card's own store).
  final int? vendorId;

  /// The checkout provider family key (the screen's `storeId`): `null` for the
  /// all-stores flow, a concrete id for the single-store flow.
  final int? storeId;

  @override
  ConsumerState<ApplyDiscountCodeView> createState() =>
      _ApplyDiscountCodeViewState();
}

class _ApplyDiscountCodeViewState
    extends ConsumerState<ApplyDiscountCodeView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Applies the entered code to this vendor's draft. A no-op unless the field
  /// actually holds a code and the vendor/draft ids are known, so an empty (or
  /// whitespace-only) field applies nothing.
  void _onApply() {
    final String code = _controller.text.trim();
    final int? vendorId = widget.vendorId;
    final String? orderGroupUuid =
        ref.read(checkoutModelProvider).orderGroup.uuid;

    if (code.isEmpty || vendorId == null || orderGroupUuid == null) return;

    ref.read(checkoutProvider(widget.storeId).notifier).applyCoupons(
          orderGroupUuid: orderGroupUuid,
          vendorId: vendorId,
          code: code,
        );
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
            onTap: _onApply,
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
