import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/repo/profile_repo.dart';











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



    state = const AsyncValue<PersonalInformationData>.loading()
        .copyWithPrevious(state);

    final result = await _repo.getProfile();

    if (!mounted) return;

    state = result.fold(
      (Failure failure) =>
          AsyncValue.error(failure.message, StackTrace.current),
      (PersonalInformationData data) => AsyncValue.data(data),
    );
  }




  void setProfileData(PersonalInformationData data) {
    if (!mounted) return;
    state = AsyncValue.data(data);
  }
}
