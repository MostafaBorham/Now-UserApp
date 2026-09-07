import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/datasources/remote/api/purchase_voucher_endpoints.dart';

/// Raw API calls for the purchase-vouchers feature.
///
/// Each method only performs the request and returns the Dio [Response]; error
/// handling and parsing live in the repository. The list endpoint is public,
/// so no auth is required (the interceptor still attaches a token if present).
class PurchaseVoucherApiService {
  final Dio _dio = DioFactory.getDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
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
