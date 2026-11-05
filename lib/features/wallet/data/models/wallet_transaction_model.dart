import 'package:equatable/equatable.dart';
import 'package:nowdelivery_user_app/core/enums/wallet_transaction_status.dart';
import 'package:nowdelivery_user_app/core/extensions/json_parsing.dart';

/// A single wallet transaction — one entry of the `transactions` list from
/// `GET /api/v1/wallet/transactions`.
///
/// The `merchant` and `reference` sub-objects are parsed into their own nested
/// models ([WalletTransactionMerchant] / [WalletTransactionReference]); both may
/// be absent on a given transaction, so both are nullable.
class WalletTransactionModel extends Equatable {
  final int? id;
  final String? type;
  final String? source;

  /// The transaction status, parsed into a type-safe [WalletTransactionStatus]
  /// (its [WalletTransactionStatus.name] keeps the raw value).
  ///
  /// Sourced from the API's `display_status`, not `status`: `status` is only the
  /// coarse processing state (`pending`/`successful`/`failed`) and never carries
  /// `refunded` — a refund arrives as `status: successful`, `display_status:
  /// refunded`. Since the color mapping needs to tell a refund apart from a
  /// plain success, it is driven by the granular `display_status`.
  final WalletTransactionStatus status;
  final String? displayStatus;

  /// The human-readable, localized status label — the `{ar, en}` translation
  /// map from the API's `display_status_label` (a bare string is mirrored into
  /// both locales by [JsonParsing.localized]).
  final Map<String, dynamic>? displayStatusLabel;
  final double? amount;
  final double? signedAmount;
  final String? amountLabel;
  final String? currency;
  final String? description;
  final String? title;
  final WalletTransactionMerchant? merchant;
  final WalletTransactionReference? reference;

  /// The card a top-up was charged to, as it was then (`payment_card`:
  /// `{brand, last_four, cardholder_name}`). Absent on anything that isn't a
  /// card top-up. `cardholder_name` was requested later (semi-final §7), so
  /// older top-ups never carry it.
  final ({String? brand, String? lastFour, String? cardholderName})?
  paymentCard;
  final double? balanceAfter;
  final String? createdAt;
  final String? occurredAt;
  final String? processedAt;

  const WalletTransactionModel({
    this.id,
    this.type,
    this.source,
    required this.status,
    this.displayStatus,
    this.displayStatusLabel,
    this.amount,
    this.signedAmount,
    this.amountLabel,
    this.currency,
    this.description,
    this.title,
    this.merchant,
    this.reference,
    this.paymentCard,
    this.balanceAfter,
    this.createdAt,
    this.occurredAt,
    this.processedAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? merchant =
        json['merchant'] as Map<String, dynamic>?;
    final Map<String, dynamic>? reference =
        json['reference'] as Map<String, dynamic>?;
    final Map<String, dynamic>? card =
        json['payment_card'] as Map<String, dynamic>?;

    return WalletTransactionModel(
      id: (json['id'] as num?)?.toInt(),
      type: json['type']?.toString(),
      source: json['source']?.toString(),
      status: WalletTransactionStatus.fromStatus(
        (json['display_status'] ?? json['status'])?.toString(),
      ),
      displayStatus: json['display_status']?.toString(),
      displayStatusLabel: json.localized('display_status_label'),
      amount: (json['amount'] as num?)?.toDouble(),
      signedAmount: (json['signed_amount'] as num?)?.toDouble(),
      amountLabel: json['amount_label']?.toString(),
      currency: json['currency']?.toString(),
      description: json['description']?.toString(),
      title: json['title']?.toString(),
      merchant: merchant == null
          ? null
          : WalletTransactionMerchant.fromJson(merchant),
      reference: reference == null
          ? null
          : WalletTransactionReference.fromJson(reference),
      paymentCard: card == null
          ? null
          : (
              brand: card['brand']?.toString(),
              lastFour: card['last_four']?.toString(),
              cardholderName: card['cardholder_name']?.toString(),
            ),
      balanceAfter: (json['balance_after'] as num?)?.toDouble(),
      createdAt: json['created_at']?.toString(),
      occurredAt: json['occurred_at']?.toString(),
      processedAt: json['processed_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'source': source,
      'status': status.name,
      'display_status': displayStatus,
      'display_status_label': displayStatusLabel,
      'amount': amount,
      'signed_amount': signedAmount,
      'amount_label': amountLabel,
      'currency': currency,
      'description': description,
      'title': title,
      'merchant': merchant?.toJson(),
      'reference': reference?.toJson(),
      'payment_card': paymentCard == null
          ? null
          : <String, dynamic>{
              'brand': paymentCard!.brand,
              'last_four': paymentCard!.lastFour,
              'cardholder_name': paymentCard!.cardholderName,
            },
      'balance_after': balanceAfter,
      'created_at': createdAt,
      'occurred_at': occurredAt,
      'processed_at': processedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    type,
    source,
    status,
    displayStatus,
    displayStatusLabel,
    amount,
    signedAmount,
    amountLabel,
    currency,
    description,
    title,
    merchant,
    reference,
    paymentCard,
    balanceAfter,
    createdAt,
    occurredAt,
    processedAt,
  ];
}

/// The `merchant` sub-object of a wallet transaction — the vendor/brand the
/// transaction relates to.
class WalletTransactionMerchant extends Equatable {
  final String? type;
  final int? id;

  /// The `{ar, en}` translation map (a bare string is mirrored into both
  /// locales by [JsonParsing.localized]).
  final Map<String, dynamic>? name;
  final String? displayName;
  final String? logoUrl;
  final int? vendorCount;

  const WalletTransactionMerchant({
    this.type,
    this.id,
    this.name,
    this.displayName,
    this.logoUrl,
    this.vendorCount,
  });

  factory WalletTransactionMerchant.fromJson(Map<String, dynamic> json) {
    return WalletTransactionMerchant(
      type: json['type']?.toString(),
      id: (json['id'] as num?)?.toInt(),
      name: json.localized('name'),
      displayName: json['display_name']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      vendorCount: (json['vendor_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'name': name,
      'display_name': displayName,
      'logo_url': logoUrl,
      'vendor_count': vendorCount,
    };
  }

  @override
  List<Object?> get props => [
    type,
    id,
    name,
    displayName,
    logoUrl,
    vendorCount,
  ];
}

/// The `reference` sub-object of a wallet transaction — what the transaction
/// points back to (e.g. the order that was refunded).
class WalletTransactionReference extends Equatable {
  final String? type;
  final int? id;
  final String? uuid;
  final String? number;

  /// Set only on an entry of [orders]: the store's name in the `lang` header's
  /// language.
  final String? storeName;

  /// A multi-store checkout's orders, on an `order_group` reference (each
  /// entry `{id, uuid, number, store_name}`). Empty otherwise.
  final List<WalletTransactionReference> orders;

  const WalletTransactionReference({
    this.type,
    this.id,
    this.uuid,
    this.number,
    this.storeName,
    this.orders = const <WalletTransactionReference>[],
  });

  factory WalletTransactionReference.fromJson(Map<String, dynamic> json) {
    return WalletTransactionReference(
      type: json['type']?.toString(),
      id: (json['id'] as num?)?.toInt(),
      uuid: json['uuid']?.toString(),
      number: json['number']?.toString(),
      storeName: json['store_name']?.toString(),
      orders: <WalletTransactionReference>[
        for (final Object? order in json['orders'] as List<dynamic>? ?? [])
          if (order is Map<String, dynamic>)
            WalletTransactionReference.fromJson(order),
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'uuid': uuid,
      'number': number,
      'store_name': storeName,
      'orders': [for (final order in orders) order.toJson()],
    };
  }

  @override
  List<Object?> get props => [type, id, uuid, number, storeName, orders];
}
