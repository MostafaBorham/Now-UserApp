/// Cross-feature input validation helpers.
///
/// Keeps a single source of truth for rules that more than one feature needs,
/// so screens and widgets don't each carry their own copy of a regex.
class AppValidator {
  const AppValidator._();


  static final RegExp _saudiPhoneRegExp = RegExp(r'^\+9665\d{8}$');

  static bool isValidSaudiPhone(String phone) {
    final String normalized = phone.replaceAll(RegExp(r'[\s-]'), '');
    return _saudiPhoneRegExp.hasMatch(normalized);
  }
}
