import 'package:equatable/equatable.dart';

/// [brand] as shown to the customer ("visa" → "Visa"), or `null` when there is
/// nothing to show. The backend's test-card mode sends `unknown` for any number
/// that isn't Visa, Mastercard or Amex, and that is not a brand name.
String? displayCardBrand(String? brand) {
  final String value = (brand ?? '').trim();
  if (value.isEmpty || value.toLowerCase() == 'unknown') return null;
  return value[0].toUpperCase() + value.substring(1);
}

/// A single saved payment card — one entry of the `cards` list from
/// `GET /api/v1/payment-methods/cards`.
///
/// The expiry fields (`expiry_month` / `expiry_year` / `expiry`) and
/// `is_expired` may all come back `null` for a given card, so every field is
/// nullable.
class CardPaymentModel extends Equatable {
  final int? id;
  final String? type;
  final String? cardholderName;
  final String? brand;
  final String? lastFour;
  final String? maskedNumber;
  final int? expiryMonth;
  final int? expiryYear;
  final String? expiry;
  final bool? isExpired;
  final bool? isDefault;

  const CardPaymentModel({
    this.id,
    this.type,
    this.cardholderName,
    this.brand,
    this.lastFour,
    this.maskedNumber,
    this.expiryMonth,
    this.expiryYear,
    this.expiry,
    this.isExpired,
    this.isDefault,
  });

  /// Whether this saved method can actually fund a top-up: a real card, not one
  /// the server already knows to be expired, and saved server-side (so it has an
  /// id to send).
  ///
  /// The top-up endpoint rejects a non-card method and a known-expired card, so
  /// an unusable entry must never be preselected as the default or offered for
  /// selection — doing so guarantees a failed charge. A `null` [type] is treated
  /// as a card and a `null` [isExpired] as not-yet-expired: both mean *unknown*,
  /// and only a positive signal is worth blocking on.
  bool get isUsable =>
      id != null && (type ?? 'card') == 'card' && isExpired != true;

  factory CardPaymentModel.fromJson(Map<String, dynamic> json) {
    return CardPaymentModel(
      id: (json['id'] as num?)?.toInt(),
      type: json['type']?.toString(),
      cardholderName: json['cardholder_name']?.toString(),
      brand: json['brand']?.toString(),
      lastFour: json['last_four']?.toString(),
      maskedNumber: json['masked_number']?.toString(),
      expiryMonth: (json['expiry_month'] as num?)?.toInt(),
      expiryYear: (json['expiry_year'] as num?)?.toInt(),
      expiry: json['expiry']?.toString(),
      isExpired: json['is_expired'] as bool?,
      isDefault: json['is_default'] as bool?,
    );
  }

  CardPaymentModel copyWith({
    int? id,
    String? type,
    String? cardholderName,
    String? brand,
    String? lastFour,
    String? maskedNumber,
    int? expiryMonth,
    int? expiryYear,
    String? expiry,
    bool? isExpired,
    bool? isDefault,
  }) {
    return CardPaymentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      cardholderName: cardholderName ?? this.cardholderName,
      brand: brand ?? this.brand,
      lastFour: lastFour ?? this.lastFour,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      expiry: expiry ?? this.expiry,
      isExpired: isExpired ?? this.isExpired,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'cardholder_name': cardholderName,
      'brand': brand,
      'last_four': lastFour,
      'masked_number': maskedNumber,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'expiry': expiry,
      'is_expired': isExpired,
      'is_default': isDefault,
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    cardholderName,
    brand,
    lastFour,
    maskedNumber,
    expiryMonth,
    expiryYear,
    expiry,
    isExpired,
    isDefault,
  ];
}
