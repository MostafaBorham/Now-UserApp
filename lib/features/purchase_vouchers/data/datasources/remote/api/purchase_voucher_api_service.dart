import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/datasources/remote/api/purchase_voucher_endpoints.dart';






class PurchaseVoucherApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();


  void cancelRequests() => _canceller.cancel();

  Future<Response> getPurchaseVouchers({int? storeId, int page = 1}) {
    return _dio.get(
      PurchaseVoucherEndpoints.purchaseVouchers,
      queryParameters: PurchaseVoucherEndpoints.listQuery(
        storeId: storeId,
        page: page,
      ),
      cancelToken: _canceller.token,
    );
  }
}
