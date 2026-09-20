import 'package:nowdelivery_user_app/core/formatters/money_formatter.dart';

/// API endpoints owned by the wallet feature.
///
/// Paths and query maps are built from the caller's arguments — the class holds
/// no request state of its own, so concurrent requests can't clobber each other.
abstract class WalletEndpoints {
  static const int _perPage = 15;

  /// The wallet balance, currency and top-up limits/suggestions.
  static const String getWalletInfo = '/api/v1/wallet';

  /// The paginated wallet transaction history.
  static const String getWalletTransactions = '/api/v1/wallet/transactions';

  static Map<String, dynamic> walletTransactionsQuery(int page) => {
    'per_page': _perPage,
    'page': page,
  };

  /// The customer's saved payment cards. Takes no parameters — it returns the
  /// whole list in one shot, so the feature never paginates cards.
  static const String getMyCards = '/api/v1/payment-methods/cards';

  /// Saves a new payment card (same collection path, POST).
  static const String addPaymentCard = getMyCards;

  /// Builds the add-card request body from the entered card details.
  ///
  /// This is the backend's **test-card** contract (raw fields, top level): the
  /// server derives brand/last-four from [cardNumber] and never persists the
  /// full number or [cvc]. A `token` must NOT be sent — the API prohibits it in
  /// this mode. `set_default` is omitted, so the backend auto-defaults the
  /// first card. [expiryYear] is the full year (e.g. 2035).
  static Map<String, dynamic> addPaymentCardBody({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvc,
  }) => <String, dynamic>{
    'cardholder_name': cardholderName,
    'card_number': cardNumber,
    'expiry_month': expiryMonth,
    'expiry_year': expiryYear,
    'cvc': cvc,
  };

  /// Updates the saved card identified by [id] (PUT, same collection path).
  static String updatePaymentCard(int id) =>
      '/api/v1/payment-methods/cards/$id';

  /// Builds the update-card body — a **partial** update (test-card mode): only
  /// the fields present are changed. [cardholderName] and the expiry are always
  /// sent (the edit form prefills them); [cardNumber]/[cvc] are sent only when
  /// re-entered, since a saved card never returns the full number or CVC to
  /// prefill. `token` is never sent in this mode.
  static Map<String, dynamic> updatePaymentCardBody({
    required String cardholderName,
    required int expiryMonth,
    required int expiryYear,
    String? cardNumber,
    String? cvc,
  }) => <String, dynamic>{
    'cardholder_name': cardholderName,
    'expiry_month': expiryMonth,
    'expiry_year': expiryYear,
    if (cardNumber != null && cardNumber.isNotEmpty) 'card_number': cardNumber,
    if (cvc != null && cvc.isNotEmpty) 'cvc': cvc,
  };

  /// Deletes the saved card identified by [id].
  static String deletePaymentCard(int id) =>
      '/api/v1/payment-methods/cards/$id';

  /// Marks the saved card identified by [id] as the default payment card.
  static String setPaymentCardDefault(int id) =>
      '/api/v1/payment-methods/cards/$id/default';

  /// Tops the wallet up with [amount] via the saved payment method.
  static const String topUpWallet = '/api/v1/wallet/top-up';

  /// Builds the top-up request body: the amount to add and the payment method
  /// to charge.
  ///
  /// [amountHalalas] is serialised as the two-decimal SAR string the endpoint
  /// documents (`"10.50"`). It travels as whole halalas right up to this point
  /// so no float ever rounds the customer's amount on the way to the wire.
  static Map<String, dynamic> topUpWalletBody({
    required int amountHalalas,
    required int paymentMethodId,
  }) => <String, dynamic>{
    'amount': formatHalalasAsSar(amountHalalas),
    'payment_method_id': paymentMethodId,
  };
}
