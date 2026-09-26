import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';

/// The delivered order the "rate your order" prompt should offer — `null` when
/// there is none: nothing delivered, everything rated, or already offered
/// once (the prompt is shown once per order).
///
/// Kept alive (not `autoDispose`) and orchestrated by the auth session: it does
/// **not** fetch on creation — [AuthSessionViewModel] loads it with the other
/// user dependencies, and it is listed in `sessionScopedProviders` so it dies
/// on logout.
final getOrderToRateProvider =
    StateNotifierProvider<GetOrderToRateViewModel, AsyncValue<OrderModel?>>(
      (Ref ref) => GetOrderToRateViewModel(),
    );

class GetOrderToRateViewModel extends StateNotifier<AsyncValue<OrderModel?>> {
  GetOrderToRateViewModel() : super(const AsyncValue.data(null));

  final OrdersRepo _repo = OrdersRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getOrderToRate() async {
    state = const AsyncValue.loading();

    final Either<Failure, OrderModel?> result = await _repo
        .getOrderToPromptForRating();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (OrderModel? order) => AsyncValue.data(order),
    );
  }

  /// Records that the prompt was shown for the current order, so it is never
  /// offered for that order again.
  void markPrompted() {
    final int? id = state.valueOrNull?.id;
    if (id == null) return;
    _repo.markRatePromptShown(id);
    state = const AsyncValue.data(null);
  }
}
