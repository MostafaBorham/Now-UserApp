import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_refresh_indicator.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/my_addresses_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

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
/// ([defaultAddressProvider]): the list is covered by a
/// [BlockingLoadingOverlay] until the response arrives, then the highlight moves
/// to the new address on success, or stays where it was and an error snackbar is
/// shown on failure.
class MyAddressScreen extends ConsumerStatefulWidget {
  const MyAddressScreen({super.key});

  @override
  ConsumerState<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends ConsumerState<MyAddressScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AddressModel>> addressesState = ref.watch(
      getMyAddressesProvider,
    );
    final bool isSettingDefault = ref.watch(defaultAddressProvider).isLoading;

    ref.listen<AsyncValue<AddressModel?>>(defaultAddressProvider, (
      AsyncValue<AddressModel?>? previous,
      AsyncValue<AddressModel?> next,
    ) {
      next.whenOrNull(
        error: (Object error, StackTrace stackTrace) =>
            ErrorSnackBar.show(context, error.toString()),
      );
    });

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
          data: (List<AddressModel> addresses) => AppRefreshIndicator(
            onRefresh: () async =>
                ref.read(getMyAddressesProvider.notifier).getMyAddresses(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (addresses.isEmpty)
                    const NoItemsWidget(emptyMessage: 'No Addresses Yet')
                  else
                    BlockingLoadingOverlay(
                      isLoading: isSettingDefault,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: addresses.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (BuildContext context, int index) =>
                            AddressCard(
                              title: addresses[index].label ?? '',
                              address: addresses[index].fullAddress ?? '',
                              isDefault: addresses[index].isDefault ?? false,
                              onSelect: () {
                                if (addresses[index].isDefault ?? false) return;
                                ref
                                    .read(defaultAddressProvider.notifier)
                                    .setDefaultAddress(
                                      addressId: addresses[index].id ?? -1,
                                    );
                              },
                              onEdit: () => context.pushNamed(
                                AppRoutes.addressDetailsScreen,
                                extra: addresses[index],
                              ),
                            ),
                      ),
                    ),
                  PrimaryAppPrefixIconButton(
                    onTap: () =>
                        context.pushNamed(AppRoutes.addNewAddressFromMapScreen),
                    title: LangKeys.addNewAddress.tr(),
                    prefixIcon: Assets.media.images.svg.addCircle.svg(
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
