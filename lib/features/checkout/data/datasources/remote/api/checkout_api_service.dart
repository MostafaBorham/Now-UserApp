import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/checkout/data/datasources/remote/api/checkout_endpoints.dart';









class CheckoutApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();




  Future<Response> checkout({int? vendorId}) {
    return _dio.post(
      CheckoutEndpoints.checkout,
      data: CheckoutEndpoints.checkoutBody(vendorId: vendorId),
      cancelToken: _canceller.token,
    );
  }




  Future<Response> checkoutForSingleStore({required int vendorId}) {
    return _dio.post(
      CheckoutEndpoints.checkoutForSingleStore(vendorId),
      cancelToken: _canceller.token,
    );
  }





  Future<Response> applyCoupon({required int vendorId, required String code}) {
    return _dio.post(
      CheckoutEndpoints.couponsApply,
      data: CheckoutEndpoints.discountApplyBody(vendorId: vendorId, code: code),
      cancelToken: _canceller.token,
    );
  }



  Future<Response> applyPurchaseVoucher({
    required int vendorId,
    required String code,
  }) {
    return _dio.post(
      CheckoutEndpoints.purchaseVouchersApply,
      data: CheckoutEndpoints.discountApplyBody(vendorId: vendorId, code: code),
      cancelToken: _canceller.token,
    );
  }





  Future<Response> confirmOrder({
    required String orderGroupUuid,
    required String idempotencyKey,
    int? addressId,
    String? paymentMethod,
    double? driverTip,
    String? notes,
    String? deliveryInstructions,
    Map<int, String>? coupons,
  }) {
    return _dio.post(
      CheckoutEndpoints.confirmOrder(orderGroupUuid),
      data: CheckoutEndpoints.confirmOrderBody(
        addressId: addressId,
        paymentMethod: paymentMethod,
        driverTip: driverTip,
        notes: notes,
        deliveryInstructions: deliveryInstructions,
        coupons: coupons,
      ),




      options: Options(headers: <String, dynamic>{
        'Idempotency-Key': idempotencyKey,
      }),
      cancelToken: _canceller.token,
    );
  }
}
