import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/repo/profile_repo.dart';

/// Single task: fetch the authenticated user's profile for the Personal
/// Information screen.
///
/// The fetch fires as soon as the provider is first watched — screens only
/// `ref.watch(getProfileProvider)` and render the [AsyncValue]. Retry (or
/// refresh after an edit) with
/// `ref.read(getProfileProvider.notifier).getProfile()`.
final getProfileProvider = StateNotifierProvider.autoDispose<
    GetProfileViewModel, AsyncValue<PersonalInformationData>>(
  (Ref ref) => GetProfileViewModel()..getProfile(),
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
}
