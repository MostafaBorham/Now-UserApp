import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_request_model.dart';
import 'package:nowdelivery_user_app/features/support/data/models/complaint_response_model.dart';
import 'package:nowdelivery_user_app/features/support/data/repo/support_repo.dart';

/// Single task: submit a support ticket (complaint) for the current user.
///
/// Starts idle (`AsyncValue.data(null)`); on success the data holds the created
/// [ComplaintResponseModel] returned by the backend. Trigger with
/// `ref.read(submitComplaintProvider.notifier).submitComplaint(complaint: ...)`
/// and watch/listen the provider to react to loading / error / success.
final submitComplaintProvider =
    StateNotifierProvider.autoDispose<SubmitComplaintViewModel,
        AsyncValue<ComplaintResponseModel?>>(
      (Ref ref) => SubmitComplaintViewModel(const AsyncValue.data(null)),
    );

class SubmitComplaintViewModel
    extends StateNotifier<AsyncValue<ComplaintResponseModel?>> {
  SubmitComplaintViewModel(super.initialState);

  final SupportRepo _repo = SupportRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> submitComplaint({
    required ComplaintRequestModel complaint,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repo.submitComplaint(complaint: complaint);

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (ComplaintResponseModel ticket) => AsyncValue.data(ticket),
    );
  }
}
