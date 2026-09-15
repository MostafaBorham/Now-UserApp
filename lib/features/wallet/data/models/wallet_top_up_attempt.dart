import 'package:equatable/equatable.dart';

/// One deliberate top-up submit, held intact across retries — and across the app
/// dying mid-request.
///
/// The server dedupes by [idempotencyKey], and only replays the original result
/// when that key arrives with the *same* amount and card: sent with different
/// parameters it is rejected, and a fresh key is a brand new operation that
/// charges again. So the three fields belong together as one record — while a
/// submit's outcome is unknown, this is exactly what a retry has to resend.
///
/// It is persisted rather than held in memory because cancelling the HTTP
/// request, closing the sheet, or the process being killed does **not** cancel
/// the attempt server-side. Losing the key would turn the customer's retry into
/// a second charge.
class WalletTopUpAttempt extends Equatable {
  /// The amount being added, in whole halalas.
  final int amountHalalas;

  /// The saved card being charged.
  final int paymentMethodId;

  /// The key the server dedupes this attempt by.
  final String idempotencyKey;

  const WalletTopUpAttempt({
    required this.amountHalalas,
    required this.paymentMethodId,
    required this.idempotencyKey,
  });

  /// Whether [amountHalalas] and [paymentMethodId] match this attempt — i.e.
  /// whether a submit of those inputs is a *retry* of this attempt (and must
  /// reuse its key) rather than a new top-up.
  bool matches({required int amountHalalas, required int paymentMethodId}) =>
      this.amountHalalas == amountHalalas &&
      this.paymentMethodId == paymentMethodId;

  /// Returns `null` rather than throwing when the stored record is incomplete,
  /// so a malformed payload is treated as "no attempt" instead of blocking every
  /// future top-up.
  static WalletTopUpAttempt? fromJson(Map<String, dynamic> json) {
    final int? amountHalalas = (json['amount_halalas'] as num?)?.toInt();
    final int? paymentMethodId = (json['payment_method_id'] as num?)?.toInt();
    final String? idempotencyKey = json['idempotency_key']?.toString();

    if (amountHalalas == null ||
        paymentMethodId == null ||
        idempotencyKey == null ||
        idempotencyKey.isEmpty) {
      return null;
    }

    return WalletTopUpAttempt(
      amountHalalas: amountHalalas,
      paymentMethodId: paymentMethodId,
      idempotencyKey: idempotencyKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount_halalas': amountHalalas,
      'payment_method_id': paymentMethodId,
      'idempotency_key': idempotencyKey,
    };
  }

  @override
  List<Object?> get props => [amountHalalas, paymentMethodId, idempotencyKey];
}
