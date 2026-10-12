import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';

/// Single task: fetch the current user's saved addresses, one page at a time.
///
/// Pagination itself — first page, next page, append, and the loading/error
/// bookkeeping — comes from [PaginatedViewModel]; only the fetch and the
/// in-place list edits are specific to addresses.
///
/// Deliberately **not** `autoDispose`: the loaded list outlives the address
/// screen. `AuthSessionViewModel` fills it at login and invalidates it at
/// logout, and the checkout delivery card reads from it.
final getMyAddressesProvider =
    StateNotifierProvider<
      GetMyAddressesViewModel,
      AsyncValue<PaginationModel<AddressModel>>
    >((Ref ref) => GetMyAddressesViewModel());

class GetMyAddressesViewModel extends PaginatedViewModel<AddressModel> {
  final AddressRepo _repo = AddressRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  @override
  Future<Either<Failure, PaginationModel<AddressModel>>> fetchPage(int page) {
    return _repo.getMyAddresses(page: page);
  }

  /// Replaces an address already on screen with its updated version, so a save
  /// on the details screen shows up without refetching the list.
  void updateAddress({required AddressModel address}) {
    _replaceItems(
      (List<AddressModel> items) => items
          .map((AddressModel item) => item.id == address.id ? address : item)
          .toList(),
      whenContains: address.id,
    );
  }

  /// Moves the "default" flag onto [address], clearing it everywhere else, and
  /// puts it first while the rest keep their order — the order the server
  /// lists them in (by `default_set_at`), so a refresh doesn't reshuffle.
  void updateDefaultInMyAddress({required AddressModel address}) {
    _replaceItems(
      (List<AddressModel> items) => <AddressModel>[
        ...items
            .where((AddressModel item) => item.id == address.id)
            .map((AddressModel item) => item.copyWith(isDefault: true)),
        ...items
            .where((AddressModel item) => item.id != address.id)
            .map((AddressModel item) => item.copyWith(isDefault: false)),
      ],
      whenContains: address.id,
    );
  }

  /// Applies [transform] to the loaded items, but only once the address
  /// [whenContains] is actually among them — an edit to an address on a page
  /// that was never loaded must not rewrite the list.
  void _replaceItems(
    List<AddressModel> Function(List<AddressModel> items) transform, {
    required int? whenContains,
  }) {
    final PaginationModel<AddressModel>? current = state.valueOrNull;
    if (current == null) return;

    final bool exists = current.data.any(
      (AddressModel item) => item.id == whenContains,
    );
    if (!exists) return;

    state = AsyncValue<PaginationModel<AddressModel>>.data(
      current.copyWithData(transform(current.data)),
    );
  }
}
