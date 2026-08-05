import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

final getMyOrdersProvider =
    StateNotifierProvider<
      GetMyOrdersViewModel,
      AsyncValue<PaginationModel<OrderModel>>
    >((Ref ref) => GetMyOrdersViewModel());

class GetMyOrdersViewModel extends PaginatedViewModel<OrderModel> {
  final OrdersRepo _repo = OrdersRepo();

  /// Fetches the first page of orders from the server the first time it is
  /// needed (the splash prefetch, then the my-orders screen). The guard makes
  /// the two callers idempotent — whoever runs first performs the fetch, the
  /// other reuses it. A forced refresh (pull-to-refresh / retry) goes through
  /// [loadFirstPage] directly and always hits the server.
  Future<void> loadOrders() async {
    if (state.hasValue) return;
    await loadFirstPage();
  }

  @override
  Future<Either<Failure, PaginationModel<OrderModel>>> fetchPage(int page) {
    return _repo.getMyOrders(page: page);
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
