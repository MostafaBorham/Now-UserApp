num formatDouble(double? value) {
  if (value == null) return 0;
  final roundedValue = (value * 10).round() / 10;

  return roundedValue == roundedValue.truncateToDouble()
      ? roundedValue.toInt()
      : roundedValue;
}
