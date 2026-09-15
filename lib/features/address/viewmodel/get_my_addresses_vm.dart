import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/address/data/repo/address_repo.dart';










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



  void updateAddress({required AddressModel address}) {
    _replaceItems(
      (List<AddressModel> items) => items
          .map((AddressModel item) => item.id == address.id ? address : item)
          .toList(),
      whenContains: address.id,
    );
  }


  void updateDefaultInMyAddress({required AddressModel address}) {
    _replaceItems(
      (List<AddressModel> items) => items
          .map(
            (AddressModel item) =>
                item.copyWith(isDefault: item.id == address.id),
          )
          .toList(),
      whenContains: address.id,
    );
  }




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
