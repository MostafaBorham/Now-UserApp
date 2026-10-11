import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_discount_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/checkout_vm.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/confirm_order_vm.dart';

/// The checkout screen's confirm button. It watches only the *loading slices*
/// of [confirmOrderProvider], [checkoutProvider] and [discountApplyingProvider],
/// so it rebuilds solely while the order is being placed, re-priced or given a
/// discount — showing a spinner and blocking taps, so an order is never placed
/// against a total that is about to change — and
/// nothing else on the page rebuilds with it. Success/error feedback stays on
/// the screen's `ref.listen` (navigation on success, snackbar on error).
class ConfirmOrderButton extends ConsumerWidget {
  const ConfirmOrderButton({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading =
        ref.watch(
          confirmOrderProvider.select(
            (AsyncValue<void> state) => state.isLoading,
          ),
        ) ||
        ref.watch(
          checkoutProvider.select(
            (AsyncValue<CheckoutModel?> state) => state.isLoading,
          ),
        ) ||
        ref.watch(discountApplyingProvider.select((int n) => n > 0));

    return PrimaryAppButton(
      title: LangKeys.confirmOrderKey.tr(),
      isLoading: isLoading,
      onTap: onConfirm,
    );
  }
}
