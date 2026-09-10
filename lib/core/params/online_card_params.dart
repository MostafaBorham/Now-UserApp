import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';

class OnlineCardParams {
  /// The saved card's server id, used to delete it. Null for cards that only
  /// exist client-side (e.g. the add-balance placeholder rows).
  final int? id;
  final String cardHolder;
  final String cardNumber;
  final OnlineCardTypes cardType;

  /// Whether this is the customer's default payment card. Drives the selection
  /// highlight in [OnlineCardRadioSelector] — the selected card is the default
  /// one, so selecting a card means making it the default.
  final bool isDefault;

  OnlineCardParams({
    this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.cardType,
    this.isDefault = false,
  });
}