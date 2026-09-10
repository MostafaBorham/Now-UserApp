import 'package:equatable/equatable.dart';

/// The customer wallet from `GET /api/v1/wallet`.
///
/// The endpoint splits its `data` payload into two maps — `wallet` (the account
/// itself) and `top_up` (the funding limits and suggested amounts). This model
/// flattens both into a single object: the [id]/[balance]/[balanceHalalas]/
/// [currency] fields come from `wallet`, and [minimum]/[maximum]/
/// [suggestedAmounts] come from `top_up`.
class WalletModel extends Equatable {
  // From the `wallet` map.
  final int? id;
  final double? balance;
  final int? balanceHalalas;
  final String? currency;

  // From the `top_up` map.
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
