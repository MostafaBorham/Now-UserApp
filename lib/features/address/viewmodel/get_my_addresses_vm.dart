import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';
import 'package:nowdelivery_user_app/features/address/viewmodel/default_address_vm.dart';

/// Single task: fetch the current user's saved addresses, one page at a time.
///
/// The first page is fetched as soon as the provider is first watched, so
/// screens only need to `ref.watch(getMyAddressesProvider)` and render the
/// [AsyncValue]. Later pages are pulled in with [loadMore], whose progress is
/// exposed separately through [GetMyAddressesViewModel.loadMoreState] so the
/// already-visible list is never replaced by a full-screen loading/error state.
final getMyAddressesProvider =
    StateNotifierProvider<
      GetMyAddressesViewModel,
      AsyncValue<PaginationModel<AddressModel>>
    >((Ref ref) => GetMyAddressesViewModel(const AsyncValue.loading(), ref));

class GetMyAddressesViewModel
    extends StateNotifier<AsyncValue<PaginationModel<AddressModel>>> {
  GetMyAddressesViewModel(super.initialState, this._ref);

  final Ref _ref;
  final AddressRepo _repo = AddressRepo();

  final ValueNotifier<AsyncValue<bool>> loadMoreState =
      ValueNotifier<AsyncValue<bool>>(const AsyncValue<bool>.data(true));

  @override
  void dispose() {
    _repo.cancelRequests();
    loadMoreState.dispose();
    super.dispose();
  }

  Future<void> getMyAddresses() async {
    state = const AsyncValue<PaginationModel<AddressModel>>.loading();

    final Either<Failure, PaginationModel<AddressModel>> result =
        await _fetchPage(1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        state = AsyncValue<PaginationModel<AddressModel>>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<AddressModel> firstPage) {
        state = AsyncValue<PaginationModel<AddressModel>>.data(firstPage);
        loadMoreState.value = AsyncValue<bool>.data(firstPage.hasMore);
        _ref
            .read(defaultAddressProvider.notifier)
            .setDefaultFromAddresses(addresses: firstPage.data);
      },
    );
  }

  Future<void> loadMore() async {
    final PaginationModel<AddressModel>? currentPage = state.valueOrNull;

    if (currentPage == null ||
        !currentPage.hasMore ||
        loadMoreState.value.isLoading) {
      return;
    }

    loadMoreState.value = const AsyncValue<bool>.loading();

    final Either<Failure, PaginationModel<AddressModel>> result =
        await _fetchPage(currentPage.currentPage + 1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        loadMoreState.value = AsyncValue<bool>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<AddressModel> newPage) {
        // Append the freshly fetched page to the visible list.
        state = AsyncValue<PaginationModel<AddressModel>>.data(
          currentPage.appendPage(newPage),
        );
        loadMoreState.value = AsyncValue<bool>.data(newPage.hasMore);
      },
    );
  }

  Future<Either<Failure, PaginationModel<AddressModel>>> _fetchPage(int page) {
    return _repo.getMyAddresses(page: page);
  }

  void addNewAddress({required AddressModel address}) {
    final PaginationModel<AddressModel>? current = state.valueOrNull;

    if (current == null) return;

    state = AsyncValue.data(
      current.copyWithData(<AddressModel>[...current.data, address]),
    );
  }

  void updateAddress({required AddressModel address}) {
    final PaginationModel<AddressModel>? current = state.valueOrNull;

    if (current == null) return;

    final bool exists = current.data.any(
      (AddressModel item) => item.id == address.id,
    );

    if (!exists) return;

    state = AsyncValue.data(
      current.copyWithData(
        current.data
            .map(
              (AddressModel item) =>
                  item.id == address.id ? address : item,
            )
            .toList(),
      ),
    );
  }

  void updateDefaultInMyAddress({required AddressModel address}) {
    final PaginationModel<AddressModel>? current = state.valueOrNull;

    if (current == null) return;

    final bool exists = current.data.any(
      (AddressModel item) => item.id == address.id,
    );

    if (!exists) return;

    state = AsyncValue.data(
      current.copyWithData(
        current.data
            .map(
              (AddressModel item) =>
                  item.copyWith(isDefault: item.id == address.id),
            )
            .toList(),
      ),
    );
  }
}
