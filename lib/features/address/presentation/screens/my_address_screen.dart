import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/server_connection_error_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/my_addresses_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

import '../../../settings/app_colors.dart';
import '../widgets/add_address_button.dart';
import '../widgets/address_card.dart';

/// "My Address" screen.
///
/// On open, addresses are loaded from [getMyAddressesProvider]:
///   - while loading  → an [AddressCardShimmer] skeleton list.
///   - on success     → one [AddressCard] per saved address (empty → [NoItemsWidget]).
///   - on failure     → a [ServerConnectionErrorWidget] with retry.
class MyAddressScreen extends ConsumerStatefulWidget {
  const MyAddressScreen({super.key});

  @override
  ConsumerState<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends ConsumerState<MyAddressScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AddressModel>> addressesState =
        ref.watch(getMyAddressesProvider);

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
                  const NoItemsWidget(
                    emptyMessage: 'No Addresses Yet',
                  )
                else
                  for (int i = 0; i < addresses.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    AddressCard(
                      title: addresses[i].label ?? '',
                      address: addresses[i].fullAddress ?? '',
                      isDefault: _selected == null
                          ? (addresses[i].isDefault ?? false)
                          : _selected == i,
                      onSelect: () => setState(() => _selected = i),
                      onEdit: () => context.pushNamed(
                        AppRoutes.addressDetailsScreen,
                        extra: true,
                      ),
                    ),
                  ],
                const SizedBox(height: 24),
                AddAddressButton(
                  onPressed: () => context.pushNamed(
                    AppRoutes.addNewAddressFromMapScreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
