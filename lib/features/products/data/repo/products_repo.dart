import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/data/models/pagination_model.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/dio/api_response.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/products/data/datasources/remote/api/products_api_service.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';






class ProductsRepo {
  final ProductsApiService _productsApiService = ProductsApiService();



  void cancelRequests() => _productsApiService.cancelRequests();

  Future<Either<Failure, PaginationModel<ProductModel>>> getProducts({
    required int page,
    String? search,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _productsApiService.getProducts(
        page: page,
        search: search,
      );

      return readApiResponse(response).map((Map<String, dynamic> body) {
        final Map<String, dynamic> data = responseData(body);

        final List<ProductModel> products =
            (data['products'] as List<dynamic>? ?? <dynamic>[])
                .whereType<Map<String, dynamic>>()
                .map(ProductModel.fromJson)
                .toList();

        return PaginationModel<ProductModel>.fromJson(
          data['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{},
          products,
        );
      });
    } on DioException catch (exception) {
      return Left(Failure(ApiErrorHandler.messageForDio(exception)));
    } catch (_) {
      // A parse error's text is a Dart type error, not a message for the
      // customer.
      return const Left(Failure(LangKeys.somethingWentWrongKey));
    }
  }

  Future<Either<Failure, ProductModel>> getProductDetails({required String productSlug}) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _productsApiService.getProductDetails(productSlug: productSlug);

      return readApiResponse(response).map((Map<String, dynamic> body) {
        final Map<String, dynamic> data = responseData(body);

        return ProductModel.fromJson(data['product']);
      });
    } on DioException catch (exception) {
      return Left(
        Failure(
          ApiErrorHandler.messageForDio(
            exception,
            notFound: LangKeys.productUnavailableKey,
          ),
        ),
      );
    } catch (_) {
      // A parse error's text is a Dart type error, not a message for the
      // customer.
      return const Left(Failure(LangKeys.somethingWentWrongKey));
    }
  }
}
