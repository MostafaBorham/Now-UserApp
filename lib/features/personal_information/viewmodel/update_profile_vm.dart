import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/repo/profile_repo.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

/// Single task: save edits from the Edit Information screen —
/// `PUT /api/v1/user/profile` for text, `POST` + multipart when the avatar
/// changed too.
///
/// The state is the request status (`data(null)` idle, `loading`, `error`) so
/// the screen can disable the Save button while in flight and surface the error
/// message. On success it pushes the fresh profile straight into
/// [getProfileProvider] (via [GetProfileViewModel.setProfileData]) so every
/// listener — the profile header, the read screen — updates immediately,
/// without a refetch.
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

  /// Saves whatever [edited] changed relative to [original]. When an [avatar]
  /// file is picked or [removeAvatar] is set, the whole update goes through
  /// POST + multipart; otherwise text-only via PUT + JSON. Returns true on
  /// success (caller pops); on failure returns false and leaves the error
  /// message in [state].
  ///
  /// Both transports are handed the *same* body — the diff from
  /// [ProfileModel.changesFrom]. They used to disagree (the JSON path sent
  /// nulls, the multipart path stripped them), so whether a blank field cleared
  /// the server value depended on whether the user happened to also change
  /// their picture.
  ///
  /// A save with nothing to send is not a request: if the user changed no text
  /// and no picture, this succeeds immediately.
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
