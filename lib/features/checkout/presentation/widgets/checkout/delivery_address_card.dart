import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

class DeliveryAddressCard extends ConsumerStatefulWidget {
  const DeliveryAddressCard({
    super.key,
    this.onAddressIdChanged,
  });

  /// Reports the id of the resolved default address (`null` when there is no
  /// default) whenever it changes. Lets the parent submit the order with this
  /// id instead of reading `orderGroup.addressId`.
  final ValueChanged<int?>? onAddressIdChanged;

  @override
  ConsumerState<DeliveryAddressCard> createState() =>
      _DeliveryAddressCardState();
}

class _DeliveryAddressCardState extends ConsumerState<DeliveryAddressCard> {
  AddressModel? _address;

  @override
  void initState() {
    super.initState();

    // Seed from the provider if it already holds data on first build, and
    // report that id up after the first frame (so the parent isn't mutated
    // mid-build).
    _address = ref.read(defaultAddressProvider).valueOrNull;
    if (_address != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAddressIdChanged?.call(_address?.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    // Only adopt a new address when the provider is in the data state.
    // On loading / error the previous address stays untouched.
    ref.listen<AsyncValue<AddressModel?>>(
      defaultAddressProvider,
      (previous, next) {
        next.whenData((address) {
          setState(() => _address = address);
          widget.onAddressIdChanged?.call(address?.id);
        });
      },
    );

    final String? fullAddress = _address?.fullAddress;

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
                LangKeys.deliveryAddressKey.tr(),
                style: AppTextStyles.style16Medium.copyWith(
                  color: colors.tertiaryContainer,
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(AppRoutes.myAddressScreen),
                child: Text(
                  LangKeys.editKey.tr(),
                  style: AppTextStyles.style14Regular.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            fullAddress ?? LangKeys.noAddressKey.tr(),
            maxLines: 3,
            style: AppTextStyles.style14Regular.copyWith(
              color: fullAddress != null ? colors.onSurface : colors.error,
            ),
          ),
        ],
      ),
    );
  }
}
