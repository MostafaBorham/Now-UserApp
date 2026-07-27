import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/checkout/data/models/checkout_model.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/confirm_order_vm.dart';

/// The checkout screen's confirm button. It watches only the *loading slice* of
/// [confirmOrderProvider], so it rebuilds solely while the confirm request is in
/// flight — showing a spinner and blocking repeat taps — and nothing else on the
/// page rebuilds with it. Success/error feedback stays on the screen's
/// `ref.listen` (navigation on success, snackbar on error).
class ConfirmOrderButton extends ConsumerWidget {
  const ConfirmOrderButton({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(
      confirmOrderProvider.select(
        (AsyncValue<CheckoutModel?> state) => state.isLoading,
      ),
    );

    return PrimaryAppButton(
      title: LangKeys.confirmOrderKey.tr(),
      isLoading: isLoading,
      onTap: onConfirm,
    );
  }
}
