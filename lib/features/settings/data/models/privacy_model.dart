import 'package:equatable/equatable.dart';

/// The `content` section of `GET /api/v1/application-information`.
///
/// Groups the app's legal/informational text blocks — terms of service,
/// privacy policy and about. Each block arrives from the server as a single
/// map holding both the localized text (keyed by locale, `ar` / `en`) and an
/// `updated_at` timestamp; this model splits every block into its localized
/// [Map] (e.g. [terms]) and its `updated_at` string (e.g. [termsUpdatedAt]).
class PrivacyModel extends Equatable {
  final Map<String, dynamic>? terms;
  final String? termsUpdatedAt;
  final Map<String, dynamic>? privacy;
  final String? privacyUpdatedAt;
  final Map<String, dynamic>? about;
  final String? aboutUpdatedAt;

  const PrivacyModel({
    this.terms,
    this.termsUpdatedAt,
    this.privacy,
    this.privacyUpdatedAt,
    this.about,
    this.aboutUpdatedAt,
  });

  factory PrivacyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PrivacyModel();
    }

    return PrivacyModel(
      terms: _translations(json['terms']),
      termsUpdatedAt: _updatedAt(json['terms']),
      privacy: _translations(json['privacy']),
      privacyUpdatedAt: _updatedAt(json['privacy']),
      about: _translations(json['about']),
      aboutUpdatedAt: _updatedAt(json['about']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms': _block(terms, termsUpdatedAt),
      'privacy': _block(privacy, privacyUpdatedAt),
      'about': _block(about, aboutUpdatedAt),
    };
  }

  /// The localized text of a content block (its `ar` / `en` values), i.e. the
  /// raw block map without its `updated_at` timestamp.
  static Map<String, dynamic>? _translations(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return Map<String, dynamic>.from(raw)..remove('updated_at');
  }

  /// The `updated_at` timestamp of a content block, as a string.
  static String? _updatedAt(dynamic raw) =>
      raw is Map<String, dynamic> ? raw['updated_at']?.toString() : null;

  /// Rebuilds a server block map from its split [translations] + [updatedAt].
  static Map<String, dynamic>? _block(
    Map<String, dynamic>? translations,
    String? updatedAt,
  ) {
    if (translations == null && updatedAt == null) return null;
    return {
      ...?translations,
      'updated_at': ?updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    terms,
    termsUpdatedAt,
    privacy,
    privacyUpdatedAt,
    about,
    aboutUpdatedAt,
  ];
}
