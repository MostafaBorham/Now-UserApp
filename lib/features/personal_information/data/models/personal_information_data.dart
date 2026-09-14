import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

/// View state for the Personal Information screen: the fetched [profile] plus
/// the resolved [avatarUrl].
///
/// [avatarUrl] comes from `data.user.avatar_url` and is null only when the user
/// has no picture. It points at a private disk, so whoever renders it must send
/// the bearer token (`ProfileAvatar` does). Assembling both halves in the
/// repository keeps the screens presentational.
class PersonalInformationData extends Equatable {
  final ProfileModel profile;
  final String? avatarUrl;

  const PersonalInformationData({required this.profile, this.avatarUrl});

  @override
  List<Object?> get props => [profile, avatarUrl];
}
