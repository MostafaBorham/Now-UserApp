import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/rate_order_request_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_order_details_vm.dart';

final rateOrderProvider = StateNotifierProvider.autoDispose
    .family<RateOrderViewModel, AsyncValue<void>, String>(
      (Ref ref, String orderUuid) =>
          RateOrderViewModel(ref: ref, orderUuid: orderUuid),
    );

class RateOrderViewModel extends StateNotifier<AsyncValue<void>> {
  RateOrderViewModel({required Ref ref, required this.orderUuid})
    : _ref = ref,
      super(const AsyncValue<void>.data(null));

  final Ref _ref;
  final OrdersRepo _repo = OrdersRepo();

  final String orderUuid;

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<String?> rateOrder({required RateOrderRequest request}) async {
    state = const AsyncValue<void>.loading();

    final Either<Failure, Unit> result = await _repo.rateOrder(
      request: request,
    );

    if (!mounted) return null;

    return result.fold(
      (Failure failure) {
        state = AsyncValue<void>.error(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        _ref
            .read(getOrderDetailsProvider(orderUuid).notifier)
            .getOrderDetails();
        state = const AsyncValue<void>.data(null);
        return null;
      },
    );
  }
}
