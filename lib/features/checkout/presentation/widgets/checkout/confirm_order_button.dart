import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/features/checkout/viewmodel/confirm_order_vm.dart';






class ConfirmOrderButton extends ConsumerWidget {
  const ConfirmOrderButton({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(
      confirmOrderProvider.select(
        (AsyncValue<void> state) => state.isLoading,
      ),
    );

    return PrimaryAppButton(
      title: LangKeys.confirmOrderKey.tr(),
      isLoading: isLoading,
      onTap: onConfirm,
    );
  }
}
