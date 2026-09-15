import 'package:nowdelivery_user_app/core/enums/online_card_types.dart';

class OnlineCardParams {


  final int? id;
  final String cardHolder;
  final String cardNumber;
  final OnlineCardTypes cardType;




  final bool isDefault;

  OnlineCardParams({
    this.id,
    required this.cardHolder,
    required this.cardNumber,
    required this.cardType,
    this.isDefault = false,
  });
}
