import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/remote/api/wallet_endpoints.dart';









class WalletApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> getWalletInfo() {
    return _dio.get(
      WalletEndpoints.getWalletInfo,
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getMyCards() {
    return _dio.get(
      WalletEndpoints.getMyCards,
      queryParameters: WalletEndpoints.myCardsQuery(),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> deletePaymentCard(int id) {
    return _dio.delete(
      WalletEndpoints.deletePaymentCard(id),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> setPaymentCardDefault(int id) {
    return _dio.patch(
      WalletEndpoints.setPaymentCardDefault(id),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> getWalletTransactions({required int page}) {
    return _dio.get(
      WalletEndpoints.getWalletTransactions,
      queryParameters: WalletEndpoints.walletTransactionsQuery(page),
      cancelToken: _canceller.token,
    );
  }







  Future<Response> topUpWallet({
    required int amount,
    required int paymentMethodId,
    required String idempotencyKey,
  }) {
    return _dio.post(
      WalletEndpoints.topUpWallet,
      data: WalletEndpoints.topUpWalletBody(
        amount: amount,
        paymentMethodId: paymentMethodId,
      ),
      options: Options(headers: <String, dynamic>{
        'Idempotency-Key': idempotencyKey,
      }),
      cancelToken: _canceller.token,
    );
  }
}
