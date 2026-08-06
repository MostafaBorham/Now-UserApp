import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/features/settings/data/models/localized_content_model.dart';

/// The `content` section of `GET /api/v1/application-information`.
///
/// Groups the app's legal/informational text blocks — terms of service,
/// privacy policy and about — each a localized [LocalizedContentModel].
class PrivacyModel extends Equatable {
  final LocalizedContentModel? terms;
  final LocalizedContentModel? privacy;
  final LocalizedContentModel? about;

  const PrivacyModel({
    this.terms,
    this.privacy,
    this.about,
  });

  factory PrivacyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PrivacyModel();
    }

    return PrivacyModel(
      terms: LocalizedContentModel.fromJson(
        json['terms'] as Map<String, dynamic>?,
      ),
      privacy: LocalizedContentModel.fromJson(
        json['privacy'] as Map<String, dynamic>?,
      ),
      about: LocalizedContentModel.fromJson(
        json['about'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms': terms?.toJson(),
      'privacy': privacy?.toJson(),
      'about': about?.toJson(),
    };
  }

  @override
  List<Object?> get props => [terms, privacy, about];
}
