



abstract class WalletEndpoints {
  static const int _perPage = 15;




  static const int _cardsPerPage = 500;


  static const String getWalletInfo = '/api/v1/wallet';


  static const String getWalletTransactions = '/api/v1/wallet/transactions';

  static Map<String, dynamic> walletTransactionsQuery(int page) => {
    'per_page': _perPage,
    'page': page,
  };


  static const String getMyCards = '/api/v1/payment-methods/cards';



  static Map<String, dynamic> myCardsQuery() => <String, dynamic>{
    'per_page': _cardsPerPage,
  };


  static String deletePaymentCard(int id) =>
      '/api/v1/payment-methods/cards/$id';


  static String setPaymentCardDefault(int id) =>
      '/api/v1/payment-methods/cards/$id/default';


  static const String topUpWallet = '/api/v1/wallet/top-up';



  static Map<String, dynamic> topUpWalletBody({
    required int amount,
    required int paymentMethodId,
  }) => <String, dynamic>{
    'amount': amount,
    'payment_method_id': paymentMethodId,
  };
}
