/// Cross-feature input validation helpers.
///
/// Keeps a single source of truth for rules that more than one feature needs,
/// so screens and widgets don't each carry their own copy of a regex.
class AppValidator {
  const AppValidator._();

  static final RegExp _saudiPhoneRegExp = RegExp(r'^\+9665\d{8}$');

  static final RegExp _saudiLocalPhoneRegExp = RegExp(r'^(?:966|0)?5?(\d{8})$');

  /// The international format the login flow uses. A user's phone *is* their
  /// identity on the backend (`User::firstOrCreate(['phone' => $phone])`), so
  /// this rule must keep producing `+9665XXXXXXXX` — a local-format login would
  /// register a second account for every existing user.
  static bool isValidSaudiPhone(String phone) {
    final String normalized = phone.replaceAll(RegExp(r'[\s-]'), '');
    return _saudiPhoneRegExp.hasMatch(normalized);
  }

  /// The 8 digits that follow the `05` prefix of a Saudi mobile number, taken
  /// from [raw] in any form the platform stores or a user types (`12345678`,
  /// `0512345678`, `+966512345678`). Null when [raw] cannot be one.
  ///
  /// Length alone disambiguates: 8 digits are the tail, and a longer entry
  /// already carries its own prefix, so only the last 8 count. That keeps a
  /// legitimate tail beginning with `0` or `5` (`0505123456` → `05123456`)
  /// from being mistaken for a duplicated prefix.
  static String? saudiLocalPhoneTail(String? raw) {
    final String digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    return _saudiLocalPhoneRegExp.firstMatch(digits)?.group(1);
  }

  /// The `+9665XXXXXXXX` international form the login flow keys users on, built
  /// from a number in any local shape the field or platform produces
  /// (`(05) 1234 5678`, `0501234567`, `+966501234567`). Null when [raw] does
  /// not hold a complete Saudi mobile number.
  static String? saudiPhoneToInternational(String? raw) {
    final String? tail = saudiLocalPhoneTail(raw);
    return tail == null ? null : '+9665$tail';
  }

  /// The number as shown to the user (e.g. on the OTP screen): the country
  /// code and the local `05` head in front of the 8 significant digits
  /// (`+9660512345678`). Returns [raw] unchanged when it is not a Saudi
  /// mobile, so callers can show whatever they were handed.
  static String saudiPhoneDisplay(String? raw) {
    final String? tail = saudiLocalPhoneTail(raw);
    return tail == null ? (raw ?? '') : '+96605$tail';
  }

  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Whether [email] is a plausible address.
  ///
  /// Deliberately permissive: the server is the authority on what it will
  /// accept, and an over-strict client regex rejects valid addresses (plus
  /// tags, long TLDs, subdomains). This exists only to catch the obvious typo
  /// before spending a round-trip on it.
  static bool isValidEmail(String email) => _emailRegExp.hasMatch(email.trim());
}
