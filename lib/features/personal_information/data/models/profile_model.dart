import 'package:equatable/equatable.dart';

/// The `data.user` payload of `GET /api/v1/user/profile`.
///
/// The server exposes the display name under both `full_name` and `name`
/// (identical); [fullName] prefers `full_name`. [phone] is the OTP login
/// identity and is read-only from the client's perspective.
class ProfileModel extends Equatable {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? gender; // 'male' | 'female' | 'other'
  final String? birthday; // 'YYYY-MM-DD'
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

  @override
  List<Object?> get props =>
      [id, fullName, email, phone, gender, birthday, nationality];
}
