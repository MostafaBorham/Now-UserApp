import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

final getMyOrdersProvider =
    StateNotifierProvider<
      GetMyOrdersViewModel,
      AsyncValue<PaginationModel<OrderModel>>
    >((Ref ref) => GetMyOrdersViewModel());

class GetMyOrdersViewModel
    extends StateNotifier<AsyncValue<PaginationModel<OrderModel>>> {
  GetMyOrdersViewModel() : super(const AsyncValue.loading());

  final OrdersRepo _repo = OrdersRepo();

  final ValueNotifier<AsyncValue<bool>> loadMoreState =
      ValueNotifier<AsyncValue<bool>>(const AsyncValue<bool>.data(true));

  Future<void> getOrders() async {
    state = const AsyncValue<PaginationModel<OrderModel>>.loading();

    final Either<Failure, PaginationModel<OrderModel>> result =
        await _fetchPage(1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        state = AsyncValue<PaginationModel<OrderModel>>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<OrderModel> firstPage) {
        state = AsyncValue<PaginationModel<OrderModel>>.data(firstPage);
        loadMoreState.value = AsyncValue<bool>.data(firstPage.hasMore);
      },
    );
  }


  Future<void> loadMore() async {
    final PaginationModel<OrderModel>? currentPage = state.valueOrNull;

    if (currentPage == null ||
        !currentPage.hasMore ||
        loadMoreState.value.isLoading) {
      return;
    }

    loadMoreState.value = const AsyncValue<bool>.loading();

    final Either<Failure, PaginationModel<OrderModel>> result =
        await _fetchPage(currentPage.currentPage + 1);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        loadMoreState.value = AsyncValue<bool>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (PaginationModel<OrderModel> newPage) {
        // Append the freshly fetched page to the visible list.
        state = AsyncValue<PaginationModel<OrderModel>>.data(
          currentPage.appendPage(newPage),
        );
        loadMoreState.value = AsyncValue<bool>.data(newPage.hasMore);
      },
    );
  }


  /// Replaces the matching order in the loaded list with [order], in place.
  ///
  /// A no-op unless the list is already loaded (`state` holds data) and it
  /// contains an order with the same identity — [OrderModel.uuid], falling back
  /// to [OrderModel.id]. Every page counter and the order's position are kept
  /// (via [PaginationModel.copyWithData]), so a status change made on the
  /// details or cancel flow shows here without a full refetch — keeping the
  /// my-orders list consistent with the details screen for the same order.
  void updateOrder(OrderModel order) {
    final PaginationModel<OrderModel>? currentPage = state.valueOrNull;
    if (currentPage == null) return;

    bool sameOrder(OrderModel existing) => order.uuid != null
        ? existing.uuid == order.uuid
        : existing.id != null && existing.id == order.id;

    final int index = currentPage.data.indexWhere(sameOrder);
    if (index == -1) return;

    final List<OrderModel> updated = List<OrderModel>.of(currentPage.data)
      ..[index] = order;

    state = AsyncValue<PaginationModel<OrderModel>>.data(
      currentPage.copyWithData(updated),
    );
  }

  Future<Either<Failure, PaginationModel<OrderModel>>> _fetchPage(int page) {
    return _repo.getMyOrders(page: page);
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    loadMoreState.dispose();
    super.dispose();
  }
}
