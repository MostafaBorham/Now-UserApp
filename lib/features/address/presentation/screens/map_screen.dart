

import 'package:dartz/dartz.dart' show Either;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/arrow_back_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/primary_app_disabled_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/maps/app_map.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/core/routing/app_routes.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/resolve_map_address_vm.dart';

class AddNewAddressFromMap extends ConsumerStatefulWidget {
  const AddNewAddressFromMap({super.key, this.address});





  final AddressModel? address;

  @override
  ConsumerState<AddNewAddressFromMap> createState() =>
      _AddNewAddressFromMapState();
}

class _AddNewAddressFromMapState extends ConsumerState<AddNewAddressFromMap> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();


    final double? lat = double.tryParse(widget.address?.latitude ?? '');
    final double? lng = double.tryParse(widget.address?.longitude ?? '');
    if (lat != null && lng != null) {
      _selectedLocation = LatLng(lat, lng);
    }
  }




  Future<void> _onSearchTapped() async {
    final LatLng? picked = await context.pushNamed<LatLng>(
      AppRoutes.addressSearchScreen,

      extra: (
        bias: _selectedLocation,
        isChangingAddress: widget.address != null,
      ),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedLocation = picked;
    });
  }




  Future<void> _onEnterAddressTapped() async {
    final LatLng? location = _selectedLocation;
    if (location == null) {
      AppToast.showError(context, LangKeys.failedToGetAddress);
      return;
    }

    final Either<Failure, AddressModel> result = await ref
        .read(resolveMapAddressProvider.notifier)
        .resolve(location);

    if (!mounted) return;

    result.fold(
      (Failure failure) => AppToast.showError(context, failure.message),




      (AddressModel resolved) => context.pushNamed<void>(
        AppRoutes.addressDetailsScreen,
        extra: (
          address: _merge(resolved),
          fromMap: true,
          isEdit: widget.address != null,
        ),
      ),
    );
  }








  AddressModel _merge(AddressModel resolved) {
    final AddressModel? editing = widget.address;
    if (editing == null) return resolved;

    return resolved.copyWith(
      id: editing.id,
      userId: editing.userId,
      label: editing.label,
      phone: editing.phone,
      buildingNumber: editing.buildingNumber,
      floor: editing.floor,
      apartment: editing.apartment,
      notes: editing.notes,
      isDefault: editing.isDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final bool isResolvingAddress = ref
        .watch(resolveMapAddressProvider)
        .isLoading;
    final bool isChangingAddress = widget.address != null;
    final String confirmLabel = isChangingAddress
        ? LangKeys.changeAddress.tr()
        : LangKeys.enterAddressKey.tr();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isChangingAddress
              ? LangKeys.changeAddress.tr()
              : LangKeys.addNewAddress.tr(),
          style: AppTextStyles.style24SemiBold.copyWith(
            color: colors.black,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: ReverseWidget(
          child: ArrowBackButton(onTap: () => context.pop()),
        ),
        actions: [
          IconButton(
            onPressed: _onSearchTapped,
            icon: Assets.media.images.svg.search.svg(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AppMap(


              currentLocation: _selectedLocation,
              onLocationChanged: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: AspectRatio(
              aspectRatio: 7,
              child: _selectedLocation != null
                  ? PrimaryAppButton(
                      title: confirmLabel,
                      isLoading: isResolvingAddress,
                      onTap: _onEnterAddressTapped,
                    )
                  : PrimaryAppDisabledButton(title: confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
