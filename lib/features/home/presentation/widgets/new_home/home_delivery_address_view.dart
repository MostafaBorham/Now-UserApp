import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/app_border_radius.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/effects/app_shimmer.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/maps/app_map.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/core/utils/auth_guard.dart';
import 'package:nowdelivery_user_app/core/utils/location_manager.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/pagination_status.dart';
import 'package:nowdelivery_user_app/core/enums/session_types.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/get_my_addresses_vm.dart';
import 'package:nowdelivery_user_app/features/auth/viewmodel/auth_session_vm.dart';

class HomeDeliveryAddressView extends ConsumerStatefulWidget {
  const HomeDeliveryAddressView({super.key});

  @override
  ConsumerState<HomeDeliveryAddressView> createState() =>
      _HomeDeliveryAddressViewState();
}

class _HomeDeliveryAddressViewState
    extends ConsumerState<HomeDeliveryAddressView> {
  final ScrollController _scrollController = ScrollController();
  late final GetMyAddressesViewModel _viewModel;




  int? _selectedAddressId;




  bool _pickedOnMap = false;
  AddressModel? _mapPickedAddress;


  bool _resolvingPick = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _viewModel = ref.read(getMyAddressesProvider.notifier);






    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isUser =
          ref.read(authSessionProvider).sessionType == SessionType.user;
      if (isUser && !ref.read(getMyAddressesProvider).hasValue) {
        _viewModel.loadFirstPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {


    if (_scrollController.position.extentAfter <= 0) {
      _viewModel.loadNextPage();
    }
  }



  LatLng? _locationOf(AddressModel address) {
    final double? lat = double.tryParse(address.latitude ?? '');
    final double? lng = double.tryParse(address.longitude ?? '');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _onAddressSelected(AddressModel address) {
    setState(() {
      _pickedOnMap = false;
      _selectedAddressId = address.id;
    });
  }





  Future<void> _onMapLocationChanged(LatLng location) async {
    setState(() => _resolvingPick = true);

    final Placemark? placemark = await LocationManager.getAddressFromLocation(
      location,
    );

    if (!mounted) return;

    if (placemark == null) {
      setState(() => _resolvingPick = false);
      AppToast.showError(context, LangKeys.failedToGetAddress);
      return;
    }

    setState(() {
      _resolvingPick = false;
      _pickedOnMap = true;
      _mapPickedAddress = AddressModel.fromPlacemark(placemark, location);
      _selectedAddressId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;




    final bool isUser =
        ref.watch(authSessionProvider.select((s) => s.sessionType)) ==
        SessionType.user;
    final AsyncValue<PaginationModel<AddressModel>> addressesState = ref.watch(
      getMyAddressesProvider,
    );



    ref.listen<AsyncValue<PaginationModel<AddressModel>>>(
      getMyAddressesProvider,
      (
        AsyncValue<PaginationModel<AddressModel>>? previous,
        AsyncValue<PaginationModel<AddressModel>> next,
      ) {
        final String? nextPageError =
            PaginationStatus<AddressModel>.from(next).nextPageError;
        if (nextPageError != null) {
          AppToast.showError(context, nextPageError);
        }
      },
    );





    final List<AddressModel> addresses =
        addressesState.valueOrNull?.data ?? const <AddressModel>[];
    AddressModel? selectedAddress;
    if (_pickedOnMap) {
      selectedAddress = _mapPickedAddress;
    } else {
      for (final AddressModel address in addresses) {
        if (address.id == _selectedAddressId) {
          selectedAddress = address;
          break;
        }
      }
      selectedAddress ??= addresses.isEmpty ? null : addresses.first;
    }




    final LatLng? selectedLocation = selectedAddress == null
        ? null
        : _locationOf(selectedAddress);






    final bool showMapPlaceholder =
        isUser && selectedLocation == null && !addressesState.hasValue;

    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),


      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.neutral300,
                    borderRadius: AppBorderRadius.brCircular30,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LangKeys.deliveryAddressKey.tr(),
                    style: AppTextStyles.style20SemiBold.copyWith(
                      color: colors.tertiaryContainer,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.clear,
                      color: colors.black,
                      applyTextScaling: true,
                      size: 20,
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: AppBorderRadius.brCircular12,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.neutral200),
                    borderRadius: AppBorderRadius.brCircular12,
                  ),
                  child: showMapPlaceholder
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: AppMap(
                                currentLocation: selectedLocation,
                                onLocationChanged: _onMapLocationChanged,
                              ),
                            ),


                            if (_resolvingPick)
                              Positioned.fill(
                                child: ColoredBox(
                                  color: colors.black.withValues(alpha: 0.15),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),




              if (isUser)
                Flexible(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: _AddressList(
                      state: addressesState,
                      selectedAddressId: selectedAddress?.id,
                      onSelect: _onAddressSelected,
                    ),
                  ),
                ),
              GestureDetector(



                onTap: () {
                  if (redirectGuestToLogin(context)) return;
                  context.pushNamed(AppRoutes.addNewAddressFromMapScreen);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.brCircular8,
                    border: Border.all(color: colors.neutral200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Assets.media.images.svg.addCircle.svg(
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          colors.primary500Main,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        LangKeys.addNewAddress.tr(),
                        style: AppTextStyles.style16Medium.copyWith(
                          color: colors.primary500Main,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (selectedLocation == null || _resolvingPick)
                  ? PrimaryAppDisabledButton(
                      title: LangKeys.confirmAddressKey.tr(),
                    )
                  : PrimaryAppButton(
                      title: LangKeys.confirmAddressKey.tr(),



                      onTap: () => context.pop(selectedAddress),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}







class _AddressList extends StatelessWidget {
  const _AddressList({
    required this.state,
    required this.selectedAddressId,
    required this.onSelect,
  });

  final AsyncValue<PaginationModel<AddressModel>> state;
  final int? selectedAddressId;
  final ValueChanged<AddressModel> onSelect;

  @override
  Widget build(BuildContext context) {
    final PaginationStatus<AddressModel> status =
        PaginationStatus<AddressModel>.from(state);



    if (!status.hasLoadedPage) return const _AddressShimmerList();

    final int loadingItemsCount = status.isNextPageLoading ? 2 : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        for (final AddressModel address in status.items)
          _AddressItem(
            icon: _iconForLabel(address.label),
            title: context.getLocalizedApiText(address.label),
            subtitle: address.fullAddress ?? '',
            highlighted: address.id == selectedAddressId,
            onTap: () => onSelect(address),
            onEdit: () => context.pushNamed(
              AppRoutes.addressDetailsScreen,
              extra: address,
            ),
          ),
        for (int i = 0; i < loadingItemsCount; i++) const _AddressItemShimmer(),
      ],
    );
  }
}





SvgGenImage _iconForLabel(Map<String, dynamic>? label) {
  final String key = (label?['en'] ?? '').toString().toLowerCase();
  return switch (key) {
    'work' => Assets.media.images.svg.workSelected,
    'other' => Assets.media.images.svg.otherSelected,
    _ => Assets.media.images.svg.homeSelected,
  };
}



class _AddressShimmerList extends StatelessWidget {
  const _AddressShimmerList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        _AddressItemShimmer(),
        _AddressItemShimmer(),
        _AddressItemShimmer(),
      ],
    );
  }
}

class _AddressItem extends StatelessWidget {
  const _AddressItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
    required this.onEdit,
  });

  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlighted ? colors.scrim : colors.primaryFixed,
          borderRadius: AppBorderRadius.brCircular12,
          border: highlighted
              ? Border.all(color: colors.surfaceContainerHigh)
              : null,
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted
                    ? colors.surfaceContainerHigh
                    : colors.onPrimaryContainer,
              ),
              child: icon.svg(
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  colors.neutral1200,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style16SemiBold.copyWith(
                      color: colors.neutral1200,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style14Regular.copyWith(
                      color: colors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: Assets.media.images.svg.editIcon.svg(
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _AddressItemShimmer extends StatelessWidget {
  const _AddressItemShimmer();

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    return AppShimmer(
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.neutral500.withValues(alpha: 0.1),
          borderRadius: AppBorderRadius.brCircular12,
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.black,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 0.6,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
