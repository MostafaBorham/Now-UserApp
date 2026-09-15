



class AppValidator {
  const AppValidator._();

  static final RegExp _saudiPhoneRegExp = RegExp(r'^\+9665\d{8}$');

  static final RegExp _saudiLocalPhoneRegExp = RegExp(r'^(?:966|0)?5?(\d{8})$');





  static bool isValidSaudiPhone(String phone) {
    final String normalized = phone.replaceAll(RegExp(r'[\s-]'), '');
    return _saudiPhoneRegExp.hasMatch(normalized);
  }









  static String? saudiLocalPhoneTail(String? raw) {
    final String digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    return _saudiLocalPhoneRegExp.firstMatch(digits)?.group(1);
  }





  static String? saudiPhoneToInternational(String? raw) {
    final String? tail = saudiLocalPhoneTail(raw);
    return tail == null ? null : '+9665$tail';
  }





  static String saudiPhoneDisplay(String? raw) {
    final String? tail = saudiLocalPhoneTail(raw);
    return tail == null ? (raw ?? '') : '+96605$tail';
  }

  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');







  static bool isValidEmail(String email) => _emailRegExp.hasMatch(email.trim());
}
