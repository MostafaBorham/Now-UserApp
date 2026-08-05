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

  /// Loads orders one page at a time. Pass [refresh] `true` (e.g. from
  /// pull-to-refresh) to discard the current pages and reload from page 1
  /// regardless of the pagination state.
  Future<void> getOrders({bool refresh = false}) async {
    final PaginationModel<OrderModel>? currentPage = refresh
        ? null
        : state.valueOrNull;

    final int nextPage;
    if (currentPage == null) {
      nextPage = 1;
    } else if (currentPage.hasMore) {
      nextPage = currentPage.currentPage + 1;
    } else {
      return;
    }

    // The first page owns the full-screen loading/error via [state]; every
    // subsequent page reports its progress through [loadMoreState] instead.
    final bool isFirstPage = currentPage == null;

    if (isFirstPage) {
      // A first-page load (initial, retry-from-error, or refresh) never has a
      // data value to preserve, so use a plain loading state. Wrapping it with
      // [copyWithPrevious] would carry over a previous error and make [when]
      // treat it as "refreshing" (skipLoadingOnRefresh), suppressing the
      // shimmer and jumping error → list with no loading state in between.
      state = const AsyncValue<PaginationModel<OrderModel>>.loading();
    } else {
      loadMoreState.value = const AsyncValue<bool>.loading();
    }

    final Either<Failure, PaginationModel<OrderModel>> result = await _repo
        .getMyOrders(page: nextPage);

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        if (isFirstPage) {
          // Plain error (no [copyWithPrevious]): the previous state is a plain
          // loading, and copying it over would carry the isLoading flag onto
          // the error, keeping [when] stuck on the shimmer instead of showing
          // the error state.
          state = AsyncValue<PaginationModel<OrderModel>>.error(
            failure.message,
            StackTrace.current,
          );
        } else {
          loadMoreState.value = AsyncValue<bool>.error(
            failure.message,
            StackTrace.current,
          );
        }
      },
      (PaginationModel<OrderModel> newPage) {
        state = AsyncValue<PaginationModel<OrderModel>>.data(
          isFirstPage ? newPage : currentPage.appendPage(newPage),
        );
        loadMoreState.value = AsyncValue<bool>.data(newPage.hasMore);
      },
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    loadMoreState.dispose();
    super.dispose();
  }
}
