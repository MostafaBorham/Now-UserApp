import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';

class ApplyDiscountCodeView extends ConsumerStatefulWidget {
  const ApplyDiscountCodeView({
    super.key,
    this.hintText,
    this.vendorId,
  });

  final String? hintText;

  /// The vendor this discount applies to (the card's own store).
  final int? vendorId;

  @override
  ConsumerState<ApplyDiscountCodeView> createState() =>
      _ApplyDiscountCodeViewState();
}

class _ApplyDiscountCodeViewState
    extends ConsumerState<ApplyDiscountCodeView> {
  final TextEditingController _controller = TextEditingController();
  bool _isApplying = false;

  /// The user tapped ✕ on the applied chip, so show the editable field again.
  /// There is no cancel API, so the applied discount stays in the summary — ✕
  /// only lets the user enter a different code.
  bool _dismissed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Applies the entered code to this vendor via `POST /api/v1/coupons/apply`.
  /// A no-op unless the field holds a code and the vendor is known.
  ///
  /// The endpoint is a stateless calculator: it returns the discount for this
  /// vendor even when the code is rejected (`applied:false` + a reason), so the
  /// result is inspected rather than the HTTP status. On acceptance the code is
  /// registered in [appliedDiscountsProvider] (feeding the invoice summary and,
  /// for coupons, the confirm-order request); a rejection or transport error is
  /// shown in a snackbar.
  Future<void> _onApply() async {
    final String code = _controller.text.trim();
    final int? vendorId = widget.vendorId;

    if (_isApplying || code.isEmpty || vendorId == null) return;

    setState(() => _isApplying = true);

    final result = await ref
        .read(checkoutProvider.notifier)
        .applyCoupon(vendorId: vendorId, code: code);

    if (!mounted) return;

    setState(() => _isApplying = false);

    result.fold(
      (failure) => AppToast.showError(context, failure.message),
      (model) {
        if (!model.applied) {
          AppToast.showError(context, model.reason ?? LangKeys.discount.tr());
          return;
        }
        ref.read(appliedDiscountsProvider.notifier).add(
              AppliedDiscountModel(
                vendorId: vendorId,
                code: code,
                discount: model.discount,
                isVoucher: false,
              ),
            );
        setState(() => _dismissed = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // Show the applied chip when this vendor's slot holds a coupon and the user
    // hasn't tapped ✕. A voucher slot (or no slot) falls back to the editable
    // field, so applying a voucher automatically de-selects the coupon chip.
    AppliedDiscountModel? slot;
    for (final AppliedDiscountModel d in ref.watch(appliedDiscountsProvider)) {
      if (d.vendorId == widget.vendorId) {
        slot = d;
        break;
      }
    }
    final bool showChip = slot != null && !slot.isVoucher && !_dismissed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: showChip
            ? _AppliedChip(
                code: slot.code,
                onClear: () => setState(() => _dismissed = true),
              )
            : _buildInputRow(colors),
      ),
    );
  }

  Widget _buildInputRow(AppColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.onPrimaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: TextField(
                controller: _controller,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                style: AppTextStyles.style14Regular.copyWith(
                  color: colors.black,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.hintText ?? LangKeys.discount.tr(),
                  hintStyle: AppTextStyles.style14Regular.copyWith(
                    color: colors.neutral500,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _isApplying ? null : _onApply,
            child: Container(
              decoration: BoxDecoration(
                color: colors.onSecondaryFixedVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _isApplying
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.black,
                        ),
                      )
                    : Text(
                        LangKeys.applyKey.tr(),
                        style: AppTextStyles.style14Medium.copyWith(
                          color: colors.black,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The applied-coupon state (Figma): the accepted code with an ✕ to reset, and
/// a green "Applied" button.
class _AppliedChip extends StatelessWidget {
  const _AppliedChip({required this.code, required this.onClear});

  final String code;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.onPrimaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 18, color: colors.neutral500),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary500Main,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                LangKeys.appliedKey.tr(),
                style: AppTextStyles.style14Medium.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
