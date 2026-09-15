import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/repo/profile_repo.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';











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















  Future<bool> save(
    ProfileModel edited, {
    required ProfileModel? original,
    File? avatar,
    bool removeAvatar = false,
  }) async {
    final bool hasMedia = avatar != null || removeAvatar;
    final Map<String, dynamic> changes = edited.changesFrom(original);

    if (changes.isEmpty && !hasMedia) return true;

    state = const AsyncValue.loading();

    final result = hasMedia
        ? await _repo.updateProfileWithMedia(
            fields: changes,
            avatar: avatar,
            removeAvatar: removeAvatar,
          )
        : await _repo.updateProfile(changes);

    if (!mounted) return false;

    return result.fold(
      (Failure failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (PersonalInformationData data) {
        state = const AsyncValue.data(null);
        _ref.read(getProfileProvider.notifier).setProfileData(data);
        return true;
      },
    );
  }
}
