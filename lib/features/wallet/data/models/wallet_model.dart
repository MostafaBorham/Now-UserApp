import 'package:equatable/equatable.dart';








class WalletModel extends Equatable {

  final int? id;
  final double? balance;
  final int? balanceHalalas;
  final String? currency;


  final double? minimum;
  final double? maximum;
  final List<double> suggestedAmounts;

  const WalletModel({
    this.id,
    this.balance,
    this.balanceHalalas,
    this.currency,
    this.minimum,
    this.maximum,
    this.suggestedAmounts = const <double>[],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> wallet =
        json['wallet'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> topUp =
        json['top_up'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return WalletModel(
      id: (wallet['id'] as num?)?.toInt(),
      balance: (wallet['balance'] as num?)?.toDouble(),
      balanceHalalas: (wallet['balance_halalas'] as num?)?.toInt(),
      currency: wallet['currency']?.toString(),
      minimum: (topUp['minimum'] as num?)?.toDouble(),
      maximum: (topUp['maximum'] as num?)?.toDouble(),
      suggestedAmounts: (topUp['suggested_amounts'] as List<dynamic>?)
              ?.map((dynamic e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet': {
        'id': id,
        'balance': balance,
        'balance_halalas': balanceHalalas,
        'currency': currency,
      },
      'top_up': {
        'minimum': minimum,
        'maximum': maximum,
        'suggested_amounts': suggestedAmounts,
      },
    };
  }

  @override
  List<Object?> get props => [
    id,
    balance,
    balanceHalalas,
    currency,
    minimum,
    maximum,
    suggestedAmounts,
  ];
}
