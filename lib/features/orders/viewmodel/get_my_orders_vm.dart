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

  /// Loads the first page (always page 1) and drives the full-screen [state].
  ///
  /// Used on screen open, pull-to-refresh and retry-from-error — every case
  /// that should reload the list from scratch. Always starts from a plain
  /// loading state (shimmer) and ends in either data or error; it never touches
  /// pagination. Subsequent pages are the job of [loadMore].
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

  /// Loads the next page and appends it to the list, reporting its progress
  /// through [loadMoreState] (never through [state], so the visible list is
  /// never replaced by a shimmer). Called when the list reaches its end.
  ///
  /// No-ops when there is no first page yet, when there are no more pages, or
  /// when a load-more request is already in flight.
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
        state = AsyncValue<PaginationModel<OrderModel>>.data(
          currentPage.appendPage(newPage),
        );
        loadMoreState.value = AsyncValue<bool>.data(newPage.hasMore);
      },
    );
  }

  /// Shared single-page request against the repo. Both [getOrders] and
  /// [loadMore] go through here so the actual API call lives in one place.
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
