import 'dart:ui';

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

  /// A colour at [key], sent as a `#RRGGBB` (or `#AARRGGBB`) hex string — the
  /// home feed themes its sections this way. Null when absent or malformed, so
  /// callers fall back to a theme colour instead of rendering a broken one.
  Color? colorHex(String key) {
    final String hex = (this[key]?.toString() ?? '').replaceFirst('#', '');
    if (hex.length != 6 && hex.length != 8) return null;
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(hex.length == 6 ? 0xFF000000 | value : value);
  }

  /// An image URL at [key], sent either as an `{download_url: ...}` object or
  /// (home-feed banner items) as a bare URL string.
  String? downloadUrl(String key) {
    final dynamic value = this[key];
    if (value is String) return value;
    return (value as Map<String, dynamic>?)?['download_url']?.toString();
  }
}
