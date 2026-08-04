/// Parsing helpers shared by the API models.
///
/// The backend is inconsistent about a couple of shapes, and every model used
/// to normalize them inline. These extensions keep that logic in one place.
extension JsonParsing on Map<String, dynamic> {
  /// A localized text field that may arrive either as a bare `String` or as a
  /// `{ar, en}` translation map. Returns it as a translation map (a bare string
  /// is mirrored into both locales).
  Map<String, dynamic>? localized(String key) {
    final dynamic value = this[key];
    return value is String
        ? {'ar': value, 'en': value}
        : value as Map<String, dynamic>?;
  }

  /// The `download_url` inside an `{download_url: ...}` image object at [key].
  String? downloadUrl(String key) =>
      (this[key] as Map<String, dynamic>?)?['download_url']?.toString();
}
