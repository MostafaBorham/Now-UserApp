import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_coupon_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_coupons_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/checkout_model_provider.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Applies the entered code to this vendor's draft. A no-op unless the field
  /// actually holds a code and the vendor/draft ids are known, so an empty (or
  /// whitespace-only) field applies nothing.
  ///
  /// On success the checkout draft refreshes automatically and the code is
  /// registered in [appliedCouponsProvider] so the confirm-order request can
  /// resend it; on failure the server's rejection reason is shown in a snackbar.
  Future<void> _onApply() async {
    final String code = _controller.text.trim();
    final int? vendorId = widget.vendorId;
    final String? orderGroupUuid =
        ref.read(checkoutModelProvider)?.orderGroup.uuid;

    if (_isApplying ||
        code.isEmpty ||
        vendorId == null ||
        orderGroupUuid == null) {
      return;
    }

    setState(() => _isApplying = true);

    final String? error = await ref
        .read(checkoutProvider.notifier)
        .applyCoupons(
          orderGroupUuid: orderGroupUuid,
          vendorId: vendorId,
          code: code,
        );

    if (!mounted) return;

    setState(() => _isApplying = false);

    if (error != null) {
      ErrorSnackBar.show(context, error);
      return;
    }

    ref.read(appliedCouponsProvider.notifier).add(
          AppliedCouponModel(vendorId: vendorId, code: code),
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: TextField(
                    controller: _controller,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.onSecondary,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      isDense: true,
                      border: InputBorder.none,
                      hintText: widget.hintText ?? LangKeys.discount.tr(),
                      hintStyle: AppTextStyles.style14Regular.copyWith(
                        color: colors.onSurface,
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
                              color: colors.onSecondary,
                            ),
                          )
                        : Text(
                            LangKeys.applyKey.tr(),
                            style: AppTextStyles.style14Medium.copyWith(
                              color: colors.onSecondary,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
