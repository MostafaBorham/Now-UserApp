import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/repo/profile_repo.dart';
import 'package:nowdelivery_user_app/features/personal_information/viewmodel/get_profile_vm.dart';

/// Single task: save edits from the Edit Information screen via
/// `PUT /api/v1/user/profile`.
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

  /// Saves [edited]. When an [avatar] file is picked or [removeAvatar] is set,
  /// the whole update goes through POST + multipart; otherwise text-only via
  /// PUT + JSON. Returns true on success (caller pops); on failure returns
  /// false and leaves the error message in [state].
  Future<bool> save(
    ProfileModel edited, {
    File? avatar,
    bool removeAvatar = false,
  }) async {
    state = const AsyncValue.loading();

    final bool hasMedia = avatar != null || removeAvatar;
    final result = hasMedia
        ? await _repo.updateProfileWithMedia(
            fields: _nonNull(edited.toUpdateJson()),
            avatar: avatar,
            removeAvatar: removeAvatar,
          )
        : await _repo.updateProfile(edited.toUpdateJson());

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

  /// Multipart can't carry null (an empty string fails the email/gender/date
  /// rules), so only send the fields the user actually filled.
  Map<String, dynamic> _nonNull(Map<String, dynamic> source) => {
    for (final MapEntry<String, dynamic> e in source.entries)
      if (e.value != null) e.key: e.value,
  };
}
