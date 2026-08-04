import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/viewmodel/pagination/paginated_view_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

/// Single task: page through the signed-in user's orders for the my-orders
/// screen.
///
/// The first page is kicked off on first watch; `loadNextPage()` and
/// `loadFirstPage()` (refresh / retry) come from [PaginatedViewModel].
final getMyOrdersProvider =
    StateNotifierProvider<
      GetMyOrdersViewModel,
      AsyncValue<PaginationModel<OrderModel>>
    >((Ref ref) => GetMyOrdersViewModel()..loadFirstPage());

class GetMyOrdersViewModel extends PaginatedViewModel<OrderModel> {
  final OrdersRepo _repo = OrdersRepo();

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