import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/orders/data/datasources/remote/api/orders_api_service.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';

class OrdersRepo {
  final OrdersApiService _ordersApiService = OrdersApiService();


  void cancelRequests() => _ordersApiService.cancelRequests();


  Future<Either<Failure, PaginationModel<OrderModel>>> getMyOrders({
    required int page,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _ordersApiService.getMyOrders(page: page);

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(ApiErrorHandler.extractErrorMessage(body)));
      }

      final Map<String, dynamic> data =
          body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final Map<String, dynamic> paginationData =
          data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final List<dynamic> rawOrders =
          data['orders'] as List<dynamic>? ?? <dynamic>[];

      final List<OrderModel> orders = rawOrders
          .map((dynamic e) => OrderModel.fromJson(e as Map<String, dynamic>?))
          .toList();

      return Right(
        PaginationModel<OrderModel>.fromJson(paginationData, orders),
      );
    } on DioException catch (exception) {
      final dynamic data = exception.response?.data;
      final Map<String, dynamic>? responseBody = data is Map<String, dynamic>
          ? data
          : null;
      return Left(Failure(ApiErrorHandler.extractErrorMessage(responseBody)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }}
