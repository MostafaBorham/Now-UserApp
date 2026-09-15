import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/applied_discount_model.dart';
import 'package:nowdelivery_user_app/features/checkout/presentation/providers/checkout/applied_discounts_provider.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_discount_vm.dart';

class ApplyDiscountCodeView extends ConsumerStatefulWidget {
  const ApplyDiscountCodeView({
    super.key,
    this.hintText,
    this.vendorId,
  });

  final String? hintText;


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










  Future<void> _onApply() async {
    final String code = _controller.text.trim();
    final int? vendorId = widget.vendorId;

    if (_isApplying || code.isEmpty || vendorId == null) return;

    setState(() => _isApplying = true);

    final result = await ref
        .read(checkoutDiscountProvider)
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;




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
                onRemove: () => ref
                    .read(appliedDiscountsProvider.notifier)
                    .remove(widget.vendorId!),
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
