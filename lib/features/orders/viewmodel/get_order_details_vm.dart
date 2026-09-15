import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';
import 'package:nowdelivery_user_app/features/orders/viewmodel/get_my_orders_vm.dart';








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
