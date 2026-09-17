/// Helpers for SAR amounts that have to survive a round trip exactly.
///
/// Money is carried as whole **halalas** rather than a `double` of riyals,
/// because a binary double cannot hold most decimal amounts: `10.5 * 100` lands
/// on `1050.0000000000002`, and comparisons against a limit inherit the same
/// drift. Text is parsed straight into halalas and formatted straight back out,
/// so what the customer typed is what gets charged.
library;

/// Halalas in one riyal.
const int halalasPerSar = 100;

/// Matches a plain positive decimal with at most two fraction digits — the only
/// shape the top-up endpoint accepts.
final RegExp _sarAmountPattern = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');

/// Parses a customer-typed SAR [amount] into whole halalas.
///
/// Returns `null` for anything that is not a plain positive decimal with at most
/// two fraction digits: an empty field, a minus sign, a thousands separator, an
/// exponent, a stray comma, or a third decimal place. Callers treat `null` as
/// "not a submittable amount" and keep the button disabled.
///
/// Only ASCII digits are recognised, which matches every other numeric field in
/// the app.
int? parseSarToHalalas(String amount) {
  final Match? match = _sarAmountPattern.firstMatch(amount.trim());
  if (match == null) return null;

  final int riyals = int.parse(match.group(1)!);
  // Pad so a single digit reads as tenths: "10.5" is 50 halalas, not 5.
  final String fraction = (match.group(2) ?? '').padRight(2, '0');

  return riyals * halalasPerSar + int.parse(fraction);
}

/// Converts a SAR amount the server sent as a JSON number into whole halalas.
///
/// Rounds, because the double that carried `10.5` over the wire may arrive a
/// hair off; server amounts are two-decimal by contract, so rounding lands on
/// the intended halalas rather than truncating a cent away.
int sarDoubleToHalalas(double amount) => (amount * halalasPerSar).round();

/// Formats whole [halalas] as the two-decimal SAR string the top-up endpoint
/// expects, e.g. `1050` → `"10.50"`. Built by integer arithmetic so no rounding
/// can occur on the way out.
String formatHalalasAsSar(int halalas) {
  final int riyals = halalas ~/ halalasPerSar;
  final String fraction = (halalas % halalasPerSar).toString().padLeft(2, '0');

  return '$riyals.$fraction';
}

/// An amount of money for display, always to two decimals: `12.5` → `"12.50"`,
/// `12` → `"12.00"`, `null` → `"0.00"`.
///
/// Every price, fee, discount, balance and total the customer reads goes
/// through this, so an amount is never shown at a different precision than it
/// is charged at. Not for ratings or distances — those keep `formatDouble`,
/// which rounds to one decimal and would turn a 12.45 price into 12.5.
///
/// This is the display counterpart to [formatHalalasAsSar]: use that one
/// wherever the string is submitted back to the server.
String formatMoney(double? value) => (value ?? 0).toStringAsFixed(2);
