import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/rate_response_model.dart';
import 'package:nowdelivery_user_app/features/support/data/repo/support_repo.dart';







final rateStoreProvider = StateNotifierProvider.autoDispose<RateStoreViewModel,
    AsyncValue<RateResponseModel?>>(
  (Ref ref) => RateStoreViewModel(const AsyncValue.data(null)),
);

class RateStoreViewModel
    extends StateNotifier<AsyncValue<RateResponseModel?>> {
  RateStoreViewModel(super.initialState);

  final SupportRepo _repo = SupportRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> rateStore({required RateRequestModel rate}) async {
    state = const AsyncValue.loading();

    final result = await _repo.rateStore(rate: rate);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (RateResponseModel rating) => AsyncValue.data(rating),
    );
  }
}
