/// A measurement shown at its natural precision, trimmed of a pointless `.0`:
/// `4.5` → `4.5`, `4.0` → `4`, `2.46` → `2.5`.
///
/// For ratings, distances and the like — quantities where one decimal is the
/// point and a trailing zero is noise. Money belongs in [formatMoney].
num formatDouble(double? value) {
  if (value == null) return 0;
  final roundedValue = (value * 10).round() / 10;

  return roundedValue == roundedValue.truncateToDouble()
      ? roundedValue.toInt()
      : roundedValue;
}
