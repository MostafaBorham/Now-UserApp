import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';

class OnlineCardParams {


  final int? id;
  final String cardHolder;
  final String cardNumber;
  final OnlineCardTypes cardType;




  final bool isDefault;

  /// Whether the card can actually fund a payment. A card that has expired (or
  /// isn't a card at all) is rendered dimmed and cannot be selected, because the
  /// server rejects it — offering it would only produce a failed charge.
  final bool isUsable;

  OnlineCardParams({
    this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.cardType,
    this.isDefault = false,
    this.isUsable = true,
  });
}
