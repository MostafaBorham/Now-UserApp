import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_response_model.dart';
import 'package:nowdelivery_user_app/features/support/data/repo/support_repo.dart';







final rateDeliveryManProvider = StateNotifierProvider.autoDispose<
    RateDeliveryManViewModel, AsyncValue<RateResponseModel?>>(
  (Ref ref) => RateDeliveryManViewModel(const AsyncValue.data(null)),
);

class RateDeliveryManViewModel
    extends StateNotifier<AsyncValue<RateResponseModel?>> {
  RateDeliveryManViewModel(super.initialState);

  final SupportRepo _repo = SupportRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> rateDeliveryMan({required RateRequestModel rate}) async {
    state = const AsyncValue.loading();

    final result = await _repo.rateDeliveryMan(rate: rate);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (RateResponseModel rating) => AsyncValue.data(rating),
    );
  }
}
