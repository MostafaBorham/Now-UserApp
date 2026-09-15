import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';








class PersonalInformationData extends Equatable {
  final ProfileModel profile;
  final String? avatarUrl;

  const PersonalInformationData({required this.profile, this.avatarUrl});

  @override
  List<Object?> get props => [profile, avatarUrl];
}
