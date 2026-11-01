import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/wallet/data/datasources/remote/api/wallet_endpoints.dart';

/// Raw API calls for the wallet feature.
///
/// Each method only performs the request and returns the Dio [Response].
/// Error handling and response parsing are intentionally left to the caller
/// (the repository layer).
///
/// Cancellation is fully encapsulated here: every request carries the token
/// of [_canceller], and callers only see the plain [cancelRequests] method.
class WalletApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
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
      cancelToken: _canceller.token,
    );
  }

  Future<Response> addPaymentCard({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvc,
    required bool setDefault,
  }) {
    return _dio.post(
      WalletEndpoints.addPaymentCard,
      data: WalletEndpoints.addPaymentCardBody(
        cardholderName: cardholderName,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: cvc,
        setDefault: setDefault,
      ),
      cancelToken: _canceller.token,
    );
  }

  Future<Response> updatePaymentCard({
    required int id,
    required String cardholderName,
    required int expiryMonth,
    required int expiryYear,
    String? cardNumber,
    String? cvc,
    bool setDefault = false,
  }) {
    return _dio.put(
      WalletEndpoints.updatePaymentCard(id),
      data: WalletEndpoints.updatePaymentCardBody(
        cardholderName: cardholderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cardNumber: cardNumber,
        cvc: cvc,
        setDefault: setDefault,
      ),
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

  /// Tops the wallet up with [amountHalalas] via [paymentMethodId].
  ///
  /// Topping up is non-idempotent: the server dedupes retries by
  /// [idempotencyKey] (same key + same body → replays the original result), so
  /// the caller reuses one key across retries of the same top-up and rotates it
  /// once the top-up succeeds or its inputs change.
  Future<Response> topUpWallet({
    required int amountHalalas,
    required int paymentMethodId,
    required String idempotencyKey,
  }) {
    return _dio.post(
      WalletEndpoints.topUpWallet,
      data: WalletEndpoints.topUpWalletBody(
        amountHalalas: amountHalalas,
        paymentMethodId: paymentMethodId,
      ),
      options: Options(headers: <String, dynamic>{
        'Idempotency-Key': idempotencyKey,
      }),
      cancelToken: _canceller.token,
    );
  }
}
