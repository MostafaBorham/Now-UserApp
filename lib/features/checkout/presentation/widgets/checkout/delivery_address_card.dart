import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

class DeliveryAddressCard extends ConsumerStatefulWidget {
  const DeliveryAddressCard({
    super.key,
  });

  @override
  ConsumerState<DeliveryAddressCard> createState() =>
      _DeliveryAddressCardState();
}

class _DeliveryAddressCardState extends ConsumerState<DeliveryAddressCard> {
  String? _fullAddress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Only adopt a new address when the provider is in the data state.
    // On loading / error the previous address string stays untouched.
    ref.listen<AsyncValue<AddressModel?>>(
      defaultAddressProvider,
      (previous, next) {
        next.whenData((address) {
          setState(() => _fullAddress = address?.fullAddress);
        });
      },
    );

    // Seed the initial value if the provider already holds data on first build.
    _fullAddress ??= ref.read(defaultAddressProvider).valueOrNull?.fullAddress;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Delivery Address',
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(AppRoutes.myAddressScreen),
                child: Text(
                  'Edit',
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _fullAddress ?? 'No Address',
            maxLines: 3,
            style: AppTextStyles.style14Regular.copyWith(
              color: _fullAddress != null ? colors.onSurface : colors.error,
            ),
          ),
        ],
      ),
    );
  }
}
