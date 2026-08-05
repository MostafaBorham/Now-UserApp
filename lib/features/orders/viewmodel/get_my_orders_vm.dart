import 'package:dartz/dartz.dart';
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

  Future<void> getOrders() async {
    final PaginationModel<OrderModel>? currentPage = state.valueOrNull;

    final int nextPage;
    if (currentPage == null) {
      nextPage = 1;
    } else if (currentPage.hasMore) {
      nextPage = currentPage.currentPage + 1;
    } else {
      return;
    }

    state = const AsyncValue<PaginationModel<OrderModel>>.loading()
        .copyWithPrevious(state);

    final Either<Failure, PaginationModel<OrderModel>> result = await _repo
        .getMyOrders(page: nextPage);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) => AsyncValue<PaginationModel<OrderModel>>.error(
        failure.message,
        StackTrace.current,
      ).copyWithPrevious(state),
      (PaginationModel<OrderModel> newPage) =>
          AsyncValue<PaginationModel<OrderModel>>.data(
            currentPage == null ? newPage : currentPage.appendPage(newPage),
          ),
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
