import 'package:equatable/equatable.dart';






class ProfileModel extends Equatable {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? gender;
  final String? birthday;
  final String? nationality;

  const ProfileModel({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.gender,
    this.birthday,
    this.nationality,
  });

  factory ProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProfileModel();

    return ProfileModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      fullName: (json['full_name'] ?? json['name'])?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      birthday: json['birthday']?.toString(),
      nationality: json['nationality']?.toString(),
    );
  }



















  Map<String, dynamic> changesFrom(ProfileModel? original) => {
    if (fullName != original?.fullName) 'full_name': fullName,
    if (email != original?.email) 'email': email,
    if (gender != original?.gender) 'gender': gender,
    if (birthday != original?.birthday) 'birthday': birthday,
    if (nationality != original?.nationality) 'nationality': nationality,
  };

  @override
  List<Object?> get props =>
      [id, fullName, email, phone, gender, birthday, nationality];
}
