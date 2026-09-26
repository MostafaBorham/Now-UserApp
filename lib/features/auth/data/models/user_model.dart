/// The authenticated user as returned by the auth endpoints
/// (the `data.user` map of the OTP verify response).
class UserModel {
  final int id;
  final String name;
  final String fullName;
  final String? email;
  final String phone;
  final String? gender;
  final String? birthday;
  final String? nationality;
  final String status;
  final bool isAdmin;
  final bool profileCompleted;
  final List<String> roles;
  final List<String> permissions;

  const UserModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthday,
    required this.nationality,
    required this.status,
    required this.isAdmin,
    required this.profileCompleted,
    required this.roles,
    required this.permissions,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String? ?? '',
      gender: map['gender'] as String?,
      birthday: map['birthday'] as String?,
      nationality: map['nationality'] as String?,
      status: map['status'] as String? ?? '',
      isAdmin: map['is_admin'] as bool? ?? false,
      profileCompleted: map['profile_completed'] as bool? ?? false,
      roles: (map['roles'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic role) => role.toString())
          .toList(),
      permissions: (map['permissions'] as List<dynamic>? ?? const <dynamic>[])
          .map((dynamic permission) => permission.toString())
          .toList(),
    );
  }
}
