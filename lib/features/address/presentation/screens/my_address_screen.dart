import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
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
import 'package:nowdelivery_user_app/features/address/presentation/widgets/address_card_shimmer.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/my_addresses_shimmer_view.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import '../widgets/address_card.dart';

class MyAddressScreen extends ConsumerStatefulWidget {
  const MyAddressScreen({super.key});

  @override
  ConsumerState<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends ConsumerState<MyAddressScreen> {
  final ScrollController _scrollController = ScrollController();
  late final GetMyAddressesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    viewModel = ref.read(getMyAddressesProvider.notifier);
    viewModel.loadMoreState.addListener(_onLoadMoreStateChanged);
    // Load the saved addresses the first time this screen opens, or retry if a
    // previous open failed; an already-loaded list is kept as-is (no refetch).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(getMyAddressesProvider).hasValue) {
        viewModel.getMyAddresses();
      }
    });
  }

  @override
  void dispose() {
    viewModel.loadMoreState.removeListener(_onLoadMoreStateChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Surfaces a load-more failure as an error snackbar, so a paging error is
  /// shown without replacing the already-visible list with a full-screen error.
  void _onLoadMoreStateChanged() {
    final AsyncValue<bool> loadMoreState = viewModel.loadMoreState.value;
    if (loadMoreState.hasError && mounted) {
      ErrorSnackBar.show(context, loadMoreState.error.toString());
    }
  }

  void _onScroll() {
    // Only load more once the very end of the list is fully visible on screen.
    // `extentAfter` is the amount of scrollable content still hidden below the
    // viewport, so it reaches 0 exactly when no part of the list tail is
    // clipped off-screen — unlike a fixed pixel threshold, which re-fires while
    // the user is still near (but not at) the bottom with the tail cut off.
    if (_scrollController.position.extentAfter <= 0) {
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final AsyncValue<PaginationModel<AddressModel>> addressesState = ref.watch(
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
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.myAddress.tr(),
        body: addressesState.when(
          loading: () => MyAddressesShimmerView(),
          error: (Object error, StackTrace stackTrace) =>
              ServerConnectionErrorWidget(
                message: error.toString(),
                onRetry: viewModel.getMyAddresses,
              ),
          data: (PaginationModel<AddressModel> page) {
            final List<AddressModel> addresses = page.data;

            return Column(
              children: [
                // Scrollable region: the address list (with load-more shimmers)
                // takes all available height so the add button below can stay
                // pinned to the bottom, off the address scroll.
                Expanded(
                  child: AppRefreshIndicator(
                    onRefresh: viewModel.getMyAddresses,
                    child: addresses.isEmpty
                        ? const NoItemsWidget(
                            isScrollable: true,
                            emptyMessage: 'No Addresses Yet',
                          )
                        : BlockingLoadingOverlay(
                            isLoading: isSettingDefault,
                            child: ValueListenableBuilder<AsyncValue<bool>>(
                              valueListenable: viewModel.loadMoreState,
                              builder:
                                  (
                                    BuildContext context,
                                    AsyncValue<bool> value,
                                    Widget? child,
                                  ) {
                                    final int loadingItemsCount =
                                        value.isLoading ? 3 : 0;
                                    return ListView.separated(
                                      controller: _scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount:
                                          addresses.length + loadingItemsCount,
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const SizedBox(height: 16),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            if (index >= addresses.length) {
                                              return const AddressCardShimmer();
                                            }
                                            return AddressCard(
                                              title: context
                                                  .getLocalizedApiText(
                                                    addresses[index].label,
                                                  ),
                                              address:
                                                  addresses[index]
                                                      .fullAddress ??
                                                  '',
                                              isDefault:
                                                  addresses[index].isDefault ??
                                                  false,
                                              onSelect: () {
                                                if (addresses[index]
                                                        .isDefault ??
                                                    false) {
                                                  return;
                                                }
                                                ref
                                                    .read(
                                                      defaultAddressProvider
                                                          .notifier,
                                                    )
                                                    .setDefaultAddress(
                                                      addressId:
                                                          addresses[index].id ??
                                                          -1,
                                                    );
                                              },
                                              onEdit: () => context.pushNamed(
                                                AppRoutes.addressDetailsScreen,
                                                extra: addresses[index],
                                              ),
                                            );
                                          },
                                    );
                                  },
                            ),
                          ),
                  ),
                ),
                // Pinned to the bottom, outside the scrollable region.
                Padding(
                  padding: EdgeInsets.only(top: screenSize.width * 0.05),
                  child: PrimaryAppPrefixIconButton(
                    onTap: () => context.pushNamed(
                      AppRoutes.addNewAddressFromMapScreen,
                    ),
                    title: LangKeys.addNewAddress.tr(),
                    prefixIcon: Assets.media.images.svg.addCircle.svg(
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
