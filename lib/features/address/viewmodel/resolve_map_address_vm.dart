import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/geocoding_repo.dart';

/// Resolves the point picked on the map into an [AddressModel].
///
/// The state is only the request status — the resolved address is returned to
/// the caller instead of being pushed into it, because the map navigates on
/// success and shows a snackbar on failure; nothing on the map itself changes
/// either way. Same shape as `PlaceAutocompleteViewModel.resolveLocation`.
final resolveMapAddressProvider =
    StateNotifierProvider.autoDispose<
      ResolveMapAddressViewModel,
      AsyncValue<void>
    >((Ref ref) => ResolveMapAddressViewModel());

class ResolveMapAddressViewModel extends StateNotifier<AsyncValue<void>> {
  ResolveMapAddressViewModel() : super(const AsyncValue<void>.data(null));

  final GeocodingRepo _repo = GeocodingRepo();

  Future<Either<Failure, AddressModel>> resolve(LatLng location) async {
    state = const AsyncValue<void>.loading();

    final Either<Failure, AddressModel> result = await _repo.addressAt(
      location,
    );

    if (mounted) state = const AsyncValue<void>.data(null);

    return result;
  }
}
