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
/// **Not** `autoDispose`: the orders are shared, cache-backed state that must
/// survive navigation (prefetched on splash, kept in memory across screen
/// visits). Disposed only on logout via `ref.invalidate(getMyOrdersProvider)`.
///
/// The fetch is **not** kicked off on first watch — splash and the screen call
/// [GetMyOrdersViewModel.loadOrders] (cache-first). `loadNextPage()` and
/// `loadFirstPage()` (refresh / retry from the API) come from [PaginatedViewModel].
final getMyOrdersProvider =
    StateNotifierProvider<
      GetMyOrdersViewModel,
      AsyncValue<PaginationModel<OrderModel>>
    >((Ref ref) => GetMyOrdersViewModel());

class GetMyOrdersViewModel extends PaginatedViewModel<OrderModel> {
  final OrdersRepo _repo = OrdersRepo();

  /// Loads the orders cache-first: if Hive already holds them the cached page is
  /// shown and **no request is made**; otherwise the first page is fetched from
  /// the API (which also refreshes the cache). A no-op once orders are already
  /// in state, so it is safe to call from both splash and the screen.
  Future<void> loadOrders() async {
    if (state.hasValue) return;

    final PaginationModel<OrderModel>? cached = _repo.getCachedOrders();
    if (cached != null) {
      state = AsyncValue<PaginationModel<OrderModel>>.data(cached);
      return;
    }

    await loadFirstPage();
  }

  /// Clears the persisted orders cache. Call on logout (alongside invalidating
  /// this provider) so the next user never sees the previous user's orders.
  Future<void> clearCache() => _repo.clearCachedOrders();

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