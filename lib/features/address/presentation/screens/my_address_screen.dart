import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/error_snackbar.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_prefix_icon_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/errors/no_items_widget.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/address_card.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/address_card_shimmer.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';

/// The user's saved addresses: pick the delivery default, edit one, or add a
/// new one from the map.
class MyAddressScreen extends ConsumerStatefulWidget {
  const MyAddressScreen({super.key});

  @override
  ConsumerState<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends ConsumerState<MyAddressScreen> {
  static const double _cardGap = 16;

  @override
  void initState() {
    super.initState();
    // The list is normally filled at login. Fetch here only if that never
    // happened or failed — an already-loaded list is kept as-is (no refetch).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(getMyAddressesProvider).hasValue) return;
      ref.read(getMyAddressesProvider.notifier).loadFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final GetMyAddressesViewModel viewModel = ref.read(
      getMyAddressesProvider.notifier,
    );
    // The overlay means "a set-default tap is in flight" — the provider is not
    // loaded on watch, so nothing else can put it in the loading state.
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
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.myAddress.tr(),
        body: Column(
          children: <Widget>[
            // Scrollable region: the address list takes all available height so
            // the add button below stays pinned, off the address scroll.
            Expanded(
              child: BlockingLoadingOverlay(
                isLoading: isSettingDefault,
                child: PaginatedView<AddressModel>(
                  provider: getMyAddressesProvider,
                  onRefresh: viewModel.loadFirstPage,
                  onLoadNextPage: viewModel.loadNextPage,
                  layout: const PaginatedListLayout(
                    separatorBuilder: _separator,
                  ),
                  placeholderBuilder: (_) => const AddressCardShimmer(),
                  nextPagePlaceholdersCount: 3,
                  emptyBuilder: (_) => NoItemsWidget(
                    isScrollable: true,
                    emptyMessage: LangKeys.noSavedAddresses.tr(),
                  ),
                  itemBuilder:
                      (BuildContext context, AddressModel address, int index) =>
                          AddressCard(
                            title: context.getLocalizedApiText(address.label),
                            address: address.fullAddress ?? '',
                            isDefault: address.isDefault ?? false,
                            onSelect: () => _onSelect(address),
                            onEdit: () => context.pushNamed(
                              AppRoutes.addressDetailsScreen,
                              extra: address,
                            ),
                          ),
                ),
              ),
            ),
            // Pinned to the bottom, outside the scrollable region.
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.sizeOf(context).width * 0.05,
              ),
              child: PrimaryAppPrefixIconButton(
                onTap: () =>
                    context.pushNamed(AppRoutes.addNewAddressFromMapScreen),
                title: LangKeys.addNewAddress.tr(),
                prefixIcon: Assets.media.images.svg.addCircle.svg(
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelect(AddressModel address) {
    // An address with no id cannot be addressed on the server — nothing to do
    // but ignore the tap, rather than send a request that can only fail.
    final int? addressId = address.id;
    if (addressId == null || (address.isDefault ?? false)) return;
    ref
        .read(defaultAddressProvider.notifier)
        .setDefaultAddress(addressId: addressId);
  }

  static Widget _separator(BuildContext context, int index) =>
      const SizedBox(height: _cardGap);
}
