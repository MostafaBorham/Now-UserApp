import 'package:dartz/dartz.dart';
import 'package:nowdelivery_user_app/core/data/repo/base_repo.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/datasources/remote/api/profile_api_service.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/personal_information_data.dart';
import 'package:nowdelivery_user_app/features/personal_information/data/models/profile_model.dart';

/// Data operations for the personal_information feature.
///
/// Every method returns `Either<Failure, T>`; the connection check and error
/// mapping live in [BaseRepo.guard]. The repo also orchestrates assembling the
/// screen's [PersonalInformationData] so the view stays presentational.
class ProfileRepo with BaseRepo {
  final ProfileApiService _api = ProfileApiService();

  void cancelRequests() => _api.cancelRequests();

  /// Fetches the authenticated user's profile and wraps it in the screen state.
  /// Avatar is deferred, so `avatarUrl` is left null.
  Future<Either<Failure, PersonalInformationData>> getProfile() {
    return guard(
      _api.getProfile,
      (data) => PersonalInformationData(
        profile: ProfileModel.fromJson(data['user'] as Map<String, dynamic>?),
      ),
    );
  }

  /// Persists the edited [body] (from [ProfileModel.toUpdateJson]) and returns
  /// the updated profile. The response mirrors the GET envelope; parse the
  /// nested `user` when present, otherwise the `data` map itself.
  Future<Either<Failure, ProfileModel>> updateProfile(
    Map<String, dynamic> body,
  ) {
    return guard(() => _api.updateProfile(body), (data) {
      final dynamic user = data['user'];
      return ProfileModel.fromJson(
        user is Map<String, dynamic> ? user : data,
      );
    });
  }
}
