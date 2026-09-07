import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/repo/profile_repo.dart';

/// Single task: hold the authenticated user's profile, shared across the whole
/// app (the profile header, the Personal Information screen, ...).
///
/// Deliberately **not** `autoDispose` and it does **not** fetch on creation:
/// it is the session orchestrator that fires [getProfile] once when a user
/// session resolves (see `AuthSessionViewModel`) and invalidates it on logout,
/// exactly like the other user dependencies. Screens only
/// `ref.watch(getProfileProvider)` and render the [AsyncValue]; retry (e.g. the
/// Personal Information error state) with
/// `ref.read(getProfileProvider.notifier).getProfile()`.
final getProfileProvider = StateNotifierProvider<GetProfileViewModel,
    AsyncValue<PersonalInformationData>>(
  (Ref ref) => GetProfileViewModel(),
);

class GetProfileViewModel
    extends StateNotifier<AsyncValue<PersonalInformationData>> {
  GetProfileViewModel() : super(const AsyncValue.loading());

  final ProfileRepo _repo = ProfileRepo();

  @override
  void dispose() {
    _repo.cancelRequests();
    super.dispose();
  }

  Future<void> getProfile() async {
    state = const AsyncValue.loading();

    final result = await _repo.getProfile();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (PersonalInformationData data) => AsyncValue.data(data),
    );
  }

  /// Replaces the held profile with a freshly-[data] copy (e.g. straight after
  /// a successful edit), so every listener updates immediately without waiting
  /// for a refetch. Called by `UpdateProfileViewModel` on save.
  void setProfileData(PersonalInformationData data) {
    if (!mounted) return;
    state = AsyncValue.data(data);
  }
}
