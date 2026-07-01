import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';

class OnlineCardParams {
  final String cardHolder;
  final String cardNumber;
  final OnlineCardTypes cardType;

  OnlineCardParams({required this.cardHolder, required this.cardNumber, required this.cardType});
}