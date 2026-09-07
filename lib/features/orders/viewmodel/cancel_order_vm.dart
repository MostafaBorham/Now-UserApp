import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_details_vm.dart';

/// One-shot action: cancel a placed order, keyed by its [orderUuid].
///
/// Nothing is requested when first watched — cancelling is a user action — so
/// the notifier starts idle (`AsyncValue.data(null)`) and the Cancel Order sheet
/// triggers it with
/// `ref.read(cancelOrderProvider(uuid).notifier).cancelOrder()`, watching the
/// loading slice to drive the button spinner.
///
/// On success the order details (this uuid's family entry) are refetched, and
/// that fetch propagates the new (cancelled) order into the my-orders list in
/// place — so both screens reflect the cancelled state without a full list
/// refetch. `state` becomes `data(null)` and `null` is returned; on failure
/// `state` becomes an error and the message is also returned so the caller can
/// surface it in a snackbar.
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
        // Cancel's response carries no order body, so refetch the details for
        // this uuid; that fetch, on success, updates the my-orders list entry
        // in place — keeping the track / details screen and the list consistent.
        _ref.read(getOrderDetailsProvider(orderUuid).notifier).getOrderDetails();
        state = const AsyncValue<void>.data(null);
        return null;
      },
    );
  }
}
