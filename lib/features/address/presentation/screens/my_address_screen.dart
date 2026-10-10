import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/dialogs/app_custom_alert_dialog.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/blocking_loading_overlay.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/lists/delete_swipe_background.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_sliver_layout.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/pagination/paginated_view.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/address_card.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/address_card_shimmer.dart';
import 'package:nowdelivery_user_app/features/address/presentation/widgets/no_addresses_view.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/delete_address_vm.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/address/presentation/utils/address_line.dart';

/// The user's saved addresses: pick the delivery default, edit one, or add a
/// new one from the map.
class MyAddressScreen extends ConsumerStatefulWidget {
  const MyAddressScreen({super.key});

  @override
  ConsumerState<MyAddressScreen> createState() => _MyAddressScreenState();
}

class _MyAddressScreenState extends ConsumerState<MyAddressScreen> {
  static const double _cardGap = 16;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    // The overlay means "an in-place action is in flight" — either setting the
    // default or deleting. Neither provider loads on watch, so nothing else can
    // put them in the loading state.
    final bool isSettingDefault = ref.watch(defaultAddressProvider).isLoading;
    final bool isDeleting = ref.watch(deleteAddressProvider).isLoading;

    ref.listen<AsyncValue<AddressModel?>>(defaultAddressProvider, (
      AsyncValue<AddressModel?>? previous,
      AsyncValue<AddressModel?> next,
    ) {
      // The next tap's loading state still carries the last error, and
      // `whenOrNull` reports it as an error again — replaying the old toast.
      if (next.isLoading) return;
      next.whenOrNull(
        error: (Object error, StackTrace stackTrace) =>
            AppToast.showError(context, error.toString()),
      );
    });

    // A delete confirms with a success snackbar and, on failure, an error one —
    // the address itself is already restored to the list by the view model.
    // Guarding on "was loading" keeps the initial data state from firing.
    ref.listen<AsyncValue<void>>(deleteAddressProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      if (previous?.isLoading != true) return;
      next.whenOrNull(
        data: (_) =>
            AppToast.showSuccess(context, LangKeys.addressDeletedSuccessfully),
        error: (Object error, StackTrace stackTrace) =>
            AppToast.showError(context, error.toString()),
      );
    });

    return Scaffold(
      backgroundColor: context.colors.white,
      body: AppWavedView(
        appBarTitle: LangKeys.myAddress.tr(),
        scrollController: _scrollController,
        body: Column(
          children: <Widget>[
            Expanded(
              child: BlockingLoadingOverlay(
                isLoading: isSettingDefault || isDeleting,
                child: PaginatedView<AddressModel>(
                  provider: getMyAddressesProvider,
                  scrollController: _scrollController,
                  onRefresh: viewModel.loadFirstPage,
                  onLoadNextPage: viewModel.loadNextPage,
                  // The list owns the top spacing AppWavedView drops when a
                  // scroll controller is wired in, so it scrolls up with the
                  // cards and flattens the wave.
                  layout: const PaginatedListLayout(
                    separatorBuilder: _separator,
                    padding: EdgeInsets.only(top: 57),
                  ),
                  placeholderBuilder: (_) => const AddressCardShimmer(),
                  nextPagePlaceholdersCount: 3,
                  emptyBuilder: (_) => const NoAddressesView(),
                  itemBuilder:
                      (BuildContext context, AddressModel address, int index) =>
                          Dismissible(
                            key: ValueKey<int?>(address.id),
                            direction: DismissDirection.horizontal,
                            background: const DeleteSwipeBackground(
                              alignment: AlignmentDirectional.centerStart,
                            ),
                            secondaryBackground: const DeleteSwipeBackground(
                              alignment: AlignmentDirectional.centerEnd,
                            ),
                            confirmDismiss: (_) => _onDelete(address),
                            child: AddressCard(
                              title: context.getLocalizedApiText(address.label),
                              address: addressLine(context, address),
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
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.sizeOf(context).width * 0.05,
              ),
              child: PrimaryAppButton(
                titleStyle: AppTextStyles.style14Medium,
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

  /// Swiping a card asks first, then fires the delete but never dismisses the
  /// card itself: returning `false` springs it back into place, and the view
  /// model removes it (by refetching the list) only once the server confirms
  /// the delete. So the address stays on screen — under the blocking overlay —
  /// until success.
  Future<bool> _onDelete(AddressModel address) async {
    bool confirmed = false;
    await AppCustomAlertDialog.show(
      context,
      (BuildContext dialogContext) => AppCustomAlertDialog(
        title: LangKeys.deleteKey.tr(),
        message: LangKeys.deleteAddressConfirmationKey.tr(),
        confirmLabel: LangKeys.deleteKey.tr(),
        onConfirm: () {
          confirmed = true;
          Navigator.of(dialogContext).pop();
        },
      ),
    );
    if (!mounted || !confirmed) return false;
    ref.read(deleteAddressProvider.notifier).deleteAddress(address: address);
    return false;
  }

  static Widget _separator(BuildContext context, int index) =>
      const SizedBox(height: _cardGap);
}
