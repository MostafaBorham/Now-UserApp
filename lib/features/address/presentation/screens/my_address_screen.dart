import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/my_addresses_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/set_default_address_vm.dart';

import '../../../settings/app_colors.dart';
import '../widgets/add_address_button.dart';
import '../widgets/address_card.dart';

/// "My Address" screen.
///
/// On open, addresses are loaded from [getMyAddressesProvider]:
///   - while loading  → an [AddressCardShimmer] skeleton list.
///   - on success     → one [AddressCard] per saved address (empty → [NoItemsWidget]).
///   - on failure     → a [ServerConnectionErrorWidget] with retry.
///
/// Tapping a non-default card asks the backend to make it the default
/// ([setDefaultAddressProvider]): the list is covered by a
/// [BlockingLoadingOverlay] until the response arrives, then the highlight moves
/// to the new address on success, or stays where it was and an error snackbar is
/// shown on failure.
class MyAddressScreen extends ConsumerStatefulWidget {
  const MyAddressScreen({super.key});

  @override
  ConsumerState<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends ConsumerState<MyAddressScreen> {
  /// Asks the backend to make [address] the default one.
  ///
  /// Already-default addresses (and entries without an id) are ignored, so no
  /// request is fired for a tap that cannot change anything.
  Future<void> _setDefaultAddress(AddressModel address) async {
    final int? addressId = address.id;

    if (addressId == null || (address.isDefault ?? false)) return;

    await ref
        .read(setDefaultAddressProvider.notifier)
        .setDefaultAddress(addressId: addressId);

    if (!mounted) return;

    ref
        .read(setDefaultAddressProvider)
        .whenOrNull(
          data: (AddressModel? defaultAddress) {
            if (defaultAddress == null) return;

            ref
                .read(getMyAddressesProvider.notifier)
                .updateCurrentDefaultAddress(defaultAddress);
          },
          error: (Object error, StackTrace stackTrace) =>
              ErrorSnackBar.show(context, error.toString()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AddressModel>> addressesState = ref.watch(
      getMyAddressesProvider,
    );
    final bool isSettingDefault = ref
        .watch(setDefaultAddressProvider)
        .isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedView(
        appBarTitle: LangKeys.myAddress.tr(),
        body: addressesState.when(
          loading: () => MyAddressesShimmerView(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.read(getMyAddressesProvider.notifier).getMyAddresses(),
              ),
          data: (List<AddressModel> addresses) => SingleChildScrollView(
            child: Column(
              children: [
                if (addresses.isEmpty)
                  const NoItemsWidget(emptyMessage: 'No Addresses Yet')
                else
                  BlockingLoadingOverlay(
                    isLoading: isSettingDefault,
                    child: Column(
                      children: [
                        for (int i = 0; i < addresses.length; i++) ...[
                          if (i > 0) const SizedBox(height: 16),
                          AddressCard(
                            title: addresses[i].label ?? '',
                            address: addresses[i].fullAddress ?? '',
                            isDefault: addresses[i].isDefault ?? false,
                            onSelect: () => _setDefaultAddress(addresses[i]),
                            onEdit: () => context.pushNamed(
                              AppRoutes.addressDetailsScreen,
                              extra: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                AddAddressButton(
                  onPressed: () =>
                      context.pushNamed(AppRoutes.addNewAddressFromMapScreen),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
