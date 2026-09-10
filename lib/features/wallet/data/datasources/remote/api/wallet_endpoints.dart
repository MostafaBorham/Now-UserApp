/// API endpoints owned by the wallet feature.
///
/// Paths and query maps are built from the caller's arguments — the class holds
/// no request state of its own, so concurrent requests can't clobber each other.
abstract class WalletEndpoints {
  static const int _perPage = 15;

  /// The saved cards are fetched in a single un-paginated shot: one large page
  /// covers every card a customer realistically has, so the list layers never
  /// deal with pages.
  static const int _cardsPerPage = 500;

  /// The wallet balance, currency and top-up limits/suggestions.
  static const String getWalletInfo = '/api/v1/wallet';

  /// The paginated wallet transaction history.
  static const String getWalletTransactions = '/api/v1/wallet/transactions';

  static Map<String, dynamic> walletTransactionsQuery(int page) => {
    'per_page': _perPage,
    'page': page,
  };

  /// The customer's saved payment cards.
  static const String getMyCards = '/api/v1/payment-methods/cards';

  /// The whole saved-cards list in one shot — a single large [_cardsPerPage]
  /// page so the feature never paginates cards.
  static Map<String, dynamic> myCardsQuery() => <String, dynamic>{
    'per_page': _cardsPerPage,
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
  static Map<String, dynamic> topUpWalletBody({
    required int amount,
    required int paymentMethodId,
  }) => <String, dynamic>{
    'amount': amount,
    'payment_method_id': paymentMethodId,
  };
}
