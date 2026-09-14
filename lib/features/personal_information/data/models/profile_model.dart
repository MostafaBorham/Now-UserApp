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

  /// Body for `PUT`/`POST /api/v1/user/profile`, limited to the server-editable
  /// keys whose value actually differs from [original]. An empty map means the
  /// user changed nothing and there is nothing to send.
  ///
  /// This is a *partial* update by design. Sending every key on every save was
  /// destructive in two ways: a field the editor could not prefill (because the
  /// profile had not loaded) was written back as null over a good server value,
  /// and a gender the two-segment toggle cannot represent was silently wiped by
  /// a user who only edited their name. Only real edits go on the wire.
  ///
  /// A key mapped to `null` is a deliberate "clear this field": the user emptied
  /// something they had filled in before. Both transports carry that — JSON
  /// sends a literal null, and dio's `FormData.fromMap` renders null as an empty
  /// string, which the backend converts back to null.
  ///
  /// `phone` is the OTP identity and is never updatable here, so it is not part
  /// of the comparison. The avatar is not a field — it travels as its own
  /// multipart part (see `ProfileApiService.updateProfileMultipart`).
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
