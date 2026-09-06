import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_details_vm.dart';

/// One-shot action: cancel a placed order, keyed by its [orderUuid].
///
/// Nothing is requested when first watched — cancelling is a user action — so
/// the notifier starts idle (`AsyncValue.data(null)`) and the Cancel Order sheet
/// triggers it with
/// `ref.read(cancelOrderProvider(uuid).notifier).cancelOrder()`, watching the
/// loading slice to drive the button spinner.
///
/// On success the order details (this uuid's family entry) and the my-orders
/// list are refetched so both reflect the new cancelled state, `state` becomes
/// `data(null)` and `null` is returned; on failure `state` becomes an error and
/// the message is also returned so the caller can surface it in a snackbar.
final cancelOrderProvider = StateNotifierProvider.autoDispose
    .family<CancelOrderViewModel, AsyncValue<void>, String>(
      (Ref ref, String orderUuid) =>
          CancelOrderViewModel(ref: ref, orderUuid: orderUuid),
    );

class CancelOrderViewModel extends StateNotifier<AsyncValue<void>> {
  CancelOrderViewModel({required Ref ref, required this.orderUuid})
    : _ref = ref,
      super(const AsyncValue<void>.data(null));

  final Ref _ref;
  final OrdersRepo _repo = OrdersRepo();

  /// The uuid of the order to cancel; also keys the details family entry this
  /// view model refetches on success.
  final String orderUuid;

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<String?> cancelOrder() async {
    state = const AsyncValue<void>.loading();

    final Either<Failure, Unit> result = await _repo.cancelOrder(
      orderUuid: orderUuid,
    );

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        // Refresh both views so the cancelled state propagates: the track /
        // details screen for this uuid, and the my-orders list.
        _ref.read(getOrderDetailsProvider(orderUuid).notifier).getOrderDetails();
        _ref.read(getMyOrdersProvider.notifier).getOrders();
        state = const AsyncValue<void>.data(null);
        return null;
      },
    );
  }
}
