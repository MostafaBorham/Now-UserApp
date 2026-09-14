import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

/// Shows the delivery instructions carried by the selected address — the
/// "directions to your address" note captured on the address screen, i.e.
/// `AddressModel.notes`. Tapping routes there to edit it, because that is the
/// only place the value is persisted: confirm-order sends an address id, not
/// instructions, so an inline field here would have nowhere to submit to.
class DeliveryInstructionsCard extends ConsumerWidget {
  const DeliveryInstructionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColorScheme colors = context.colors;
    final AddressModel? address = ref.watch(defaultAddressProvider).valueOrNull;
    final String? instructions = address?.notes?.trim().isEmpty ?? true
        ? null
        : address!.notes;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.pushNamed(AppRoutes.myAddressScreen),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              LangKeys.deliveryInstructionsKey.tr(),
              style: AppTextStyles.style16Medium.copyWith(
                color: colors.tertiaryContainer,
              ),
            ),
            Text(
              instructions ?? LangKeys.addInstructionsHintKey.tr(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style14Regular.copyWith(
                color: instructions == null ? colors.neutral500 : colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
