import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/datasources/remote/api/purchase_voucher_api_service.dart';
import 'package:nowdelivery_user_app/features/purchase_vouchers/data/models/purchase_voucher_model.dart';

/// Data operations of the purchase-vouchers feature. Every method returns
/// `Either<Failure, T>`.
class PurchaseVoucherRepo {
  final PurchaseVoucherApiService _apiService = PurchaseVoucherApiService();

  void cancelRequests() => _apiService.cancelRequests();

  /// Fetches one page of vouchers. [storeId] returns platform-wide vouchers
  /// plus that store's vouchers; `null` returns everything.
  Future<Either<Failure, PaginationModel<PurchaseVoucherModel>>>
  getPurchaseVouchers({int? storeId, int page = 1}) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _apiService.getPurchaseVouchers(
        storeId: storeId,
        page: page,
      );

      return readApiResponse(response).map((Map<String, dynamic> body) {
        final Map<String, dynamic> data = responseData(body);

        final Map<String, dynamic> paginationData =
            data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final List<dynamic> rawVouchers =
            data['purchase_vouchers'] as List<dynamic>? ?? <dynamic>[];

        final List<PurchaseVoucherModel> vouchers = rawVouchers
            .whereType<Map<String, dynamic>>()
            .map(PurchaseVoucherModel.fromJson)
            .toList();

        return PaginationModel<PurchaseVoucherModel>.fromJson(
          paginationData,
          vouchers,
        );
      });
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (_) {
      // A parse error's text is a Dart type error, not a message for the
      // customer.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }
}
