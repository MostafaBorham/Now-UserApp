import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';

/// Single task: fetch one order's full details by its [orderUuid].
///
/// A `family` keyed by the order uuid: each order details screen watches its own
/// view model and state, so opening several orders never shares (or clobbers)
/// another's data. The request starts as soon as a uuid is first watched
/// (`..getOrderDetails()` in the provider factory); `getOrderDetails()` also
/// doubles as the refresh / retry entry point.
final getOrderDetailsProvider = StateNotifierProvider.autoDispose
    .family<GetOrderDetailsViewModel, AsyncValue<OrderModel>, String>(
      (Ref ref, String orderUuid) =>
          GetOrderDetailsViewModel(ref: ref, orderUuid: orderUuid)
            ..getOrderDetails(),
    );

class GetOrderDetailsViewModel extends StateNotifier<AsyncValue<OrderModel>> {
  GetOrderDetailsViewModel({required Ref ref, required this.orderUuid})
    : _ref = ref,
      super(const AsyncValue<OrderModel>.loading());

  final Ref _ref;
  final OrdersRepo _repo = OrdersRepo();

  /// The uuid of the order these details belong to, kept so refresh / retry asks
  /// for the same order.
  final String orderUuid;

  Future<void> getOrderDetails() async {
    state = const AsyncValue<OrderModel>.loading();

    final Either<Failure, OrderModel> result = await _repo.getOrderDetails(
      orderUuid: orderUuid,
    );

    if (!mounted) return;

    result.fold(
      (Failure failure) {
        state = AsyncValue<OrderModel>.error(
          failure.message,
          StackTrace.current,
        );
      },
      (OrderModel order) {
        state = AsyncValue<OrderModel>.data(order);
        // Propagate the freshly fetched order into the my-orders list so both
        // screens show the same state (no-op if the list isn't loaded or the
        // order isn't in it).
        _ref.read(getMyOrdersProvider.notifier).updateOrder(order);
      },
    );
  }

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }
}
