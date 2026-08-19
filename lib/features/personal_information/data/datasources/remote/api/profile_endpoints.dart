/// API endpoints owned by the personal_information feature.
abstract class ProfileEndpoints {
  /// The authenticated user's profile: `GET` reads it, `PUT` updates it.
  static const String profile = '/api/v1/user/profile';
}
