import 'package:equatable/equatable.dart';

/// A single localized content block from `GET /api/v1/application-information`.
///
/// Used for each entry inside `content` (terms / privacy / about): it carries
/// the Arabic and English text plus its version and last-update timestamp.
class LocalizedContentModel extends Equatable {
  final String? ar;
  final String? en;
  final int? version;
  final String? updatedAt;

  const LocalizedContentModel({
    this.ar,
    this.en,
    this.version,
    this.updatedAt,
  });

  factory LocalizedContentModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LocalizedContentModel();
    }

    return LocalizedContentModel(
      ar: json['ar']?.toString(),
      en: json['en']?.toString(),
      version: (json['version'] as num?)?.toInt(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
      'en': en,
      'version': version,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [ar, en, version, updatedAt];
}
