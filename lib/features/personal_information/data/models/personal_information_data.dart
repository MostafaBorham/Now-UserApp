import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

/// View state for the Personal Information screen: the fetched [profile] plus
/// the resolved [avatarUrl].
///
/// Avatar wiring lives in a separate Attachments subsystem and is deferred, so
/// [avatarUrl] is currently always `null`. Assembling the data here (in the
/// repository) keeps the screen presentational and leaves room to fold in the
/// avatar later without reshaping the screen or its view model.
class PersonalInformationData extends Equatable {
  final ProfileModel profile;
  final String? avatarUrl;

  const PersonalInformationData({required this.profile, this.avatarUrl});

  @override
  List<Object?> get props => [profile, avatarUrl];
}
