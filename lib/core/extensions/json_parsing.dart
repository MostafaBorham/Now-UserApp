import 'dart:ui';





extension JsonParsing on Map<String, dynamic> {



  Map<String, dynamic>? localized(String key) {
    final dynamic value = this[key];
    return value is String
        ? {'ar': value, 'en': value}
        : value as Map<String, dynamic>?;
  }




  Color? colorHex(String key) {
    final String hex = (this[key]?.toString() ?? '').replaceFirst('#', '');
    if (hex.length != 6 && hex.length != 8) return null;
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(hex.length == 6 ? 0xFF000000 | value : value);
  }



  String? downloadUrl(String key) {
    final dynamic value = this[key];
    if (value is String) return value;
    return (value as Map<String, dynamic>?)?['download_url']?.toString();
  }
}
