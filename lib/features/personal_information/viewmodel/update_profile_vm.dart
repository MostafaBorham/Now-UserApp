import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/repo/profile_repo.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

/// Single task: save edits from the Edit Information screen via
/// `PUT /api/v1/user/profile`.
///
/// The state is the request status (`data(null)` idle, `loading`, `error`) so
/// the screen can disable the Save button while in flight and surface the error
/// message. On success it invalidates [getProfileProvider] so the read screen
/// shows the fresh values when the user pops back.
final updateProfileProvider =
    StateNotifierProvider.autoDispose<UpdateProfileViewModel, AsyncValue<void>>(
  (Ref ref) => UpdateProfileViewModel(ref),
);

class UpdateProfileViewModel extends StateNotifier<AsyncValue<void>> {
  UpdateProfileViewModel(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  final ProfileRepo _repo = ProfileRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  /// Saves [edited]. Returns true on success (caller pops); on failure returns
  /// false and leaves the error message in [state].
  Future<bool> save(ProfileModel edited) async {
    state = const AsyncValue.loading();

    final result = await _repo.updateProfile(edited.toUpdateJson());

    if (!mounted) return false;

    return result.fold(
      (Failure failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(getProfileProvider);
        return true;
      },
    );
  }
}
