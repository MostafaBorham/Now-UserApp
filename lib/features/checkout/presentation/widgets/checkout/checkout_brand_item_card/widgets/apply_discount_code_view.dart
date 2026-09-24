import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/selected_store_coupons_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_discount_vm.dart';
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
  void initState() {
    super.initState();
    // A coupon picked on this store's details screen is the user's "apply",
    // made earlier — so honour it as soon as this card exists, without them
    // retyping the code here.
    //
    // Post-frame, not inline: the first build is what starts watching the
    // `autoDispose` [appliedDiscountsProvider], and the result must land on a
    // provider something keeps alive.
    final String? picked = ref.read(
      selectedStoreCouponsProvider,
    )[widget.vendorId];
    if (picked != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _apply(picked);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Applies [code] to this vendor via `POST /api/v1/coupons/apply` — either
  /// the code typed in the field, or the one picked on the store's details
  /// screen. A no-op unless there is a code and the vendor is known.
  ///
  /// The endpoint is a stateless calculator: it returns the discount for this
  /// vendor even when the code is rejected (`applied:false` + a reason), so the
  /// result is inspected rather than the HTTP status. On acceptance the code is
  /// registered in [appliedDiscountsProvider] (feeding the invoice summary and
  /// the place request); a rejection or transport error is
  /// shown in a snackbar.
  ///
  /// Registering takes the vendor's single discount slot, so an accepted coupon
  /// cancels a purchase voucher applied to the same vendor — that cancellation
  /// is announced in a toast.
  Future<void> _apply(String code) async {
    final int? vendorId = widget.vendorId;

    if (_isApplying || code.isEmpty || vendorId == null) return;

    setState(() => _isApplying = true);

    final result = await ref
        .read(checkoutDiscountProvider)
        .applyCoupon(
          vendorId: vendorId,
          code: code,
          addressId: ref.read(checkoutProvider.notifier).addressId,
        );

    if (!mounted) return;

    setState(() => _isApplying = false);

    result.fold(
      (failure) => AppToast.showError(context, failure.message),
      (model) {
        if (!model.applied) {
          // A pick the server won't honour (expired, under the minimum) must
          // not nag on every checkout open, nor stay highlighted back on the
          // store screen as if it were waiting to work.
          _forgetPick(vendorId);
          AppToast.showError(context, model.reason ?? LangKeys.discount.tr());
          return;
        }
        final AppliedDiscountModel? replaced =
            ref.read(appliedDiscountsProvider.notifier).add(
                  AppliedDiscountModel(
                    vendorId: vendorId,
                    code: code,
                    isVoucher: false,
                  ),
                );
        // The field is about to be swapped for the applied chip; clear it so a
        // later cancellation (a voucher taking this slot) doesn't bring the
        // dead code back as editable text.
        _controller.clear();
        // A vendor carries one discount, so this coupon just cancelled that
        // vendor's voucher — say so rather than letting the highlight silently
        // vanish from the strip.
        if (replaced != null && replaced.isVoucher) {
          AppToast.showSuccess(
            context,
            LangKeys.voucherReplacedByCouponKey.tr(),
          );
        }
      },
    );
  }

  /// Drops [vendorId]'s store-details coupon pick, so that screen's strip and
  /// this card agree and a later checkout doesn't re-apply a code the user is
  /// done with.
  void _forgetPick(int vendorId) => ref
      .read(selectedStoreCouponsProvider.notifier)
      .update(
        (Map<int, String> picks) => <int, String>{...picks}..remove(vendorId),
      );

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    // Show the applied chip when this vendor's slot holds a coupon. A voucher
    // slot (or no slot) falls back to the editable field, so applying a voucher
    // automatically de-selects the coupon chip.
    AppliedDiscountModel? slot;
    for (final AppliedDiscountModel d in ref.watch(appliedDiscountsProvider)) {
      if (d.vendorId == widget.vendorId) {
        slot = d;
        break;
      }
    }
    final bool showChip = slot != null && !slot.isVoucher;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryFixed,
        borderRadius: BorderRadius.circular(12),
        border: showChip ? Border.all(color: colors.primary500Main) : null,
      ),
      child: IntrinsicHeight(
        child: showChip
            ? _AppliedChip(
                code: slot.code,
                onRemove: () {
                  ref
                      .read(appliedDiscountsProvider.notifier)
                      .remove(widget.vendorId!);
                  _forgetPick(widget.vendorId!);
                },
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
            onTap: _isApplying
                ? null
                : () => _apply(_controller.text.trim()),
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

/// The applied-coupon state (Figma): a solid primary-500 "Applied" button
/// alongside a neutral pill holding a remove (×) control and the accepted code.
class _AppliedChip extends StatelessWidget {
  const _AppliedChip({required this.code, required this.onRemove});

  final String code;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.onPrimaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    code,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: colors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: colors.primary500Main,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            LangKeys.appliedKey.tr(),
            style: AppTextStyles.style14Medium.copyWith(
              color: colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
