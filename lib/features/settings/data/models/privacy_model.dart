import 'package:equatable/equatable.dart';

/// The `content` section of `GET /api/v1/application-information`.
///
/// Groups the app's legal/informational text blocks — terms of service,
/// privacy policy and about — each a localized map keyed by locale
/// (`ar` / `en`), as returned by the server.
class PrivacyModel extends Equatable {
  final Map<String, dynamic>? terms;
  final Map<String, dynamic>? privacy;
  final Map<String, dynamic>? about;

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
      terms: json['terms'] as Map<String, dynamic>?,
      privacy: json['privacy'] as Map<String, dynamic>?,
      about: json['about'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms': terms,
      'privacy': privacy,
      'about': about,
    };
  }

  @override
  List<Object?> get props => [terms, privacy, about];
}
