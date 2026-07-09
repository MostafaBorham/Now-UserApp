import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/features/categories/data/datasources/remote/api/categories_api_service.dart';
import 'package:nowdelivery_user_app/features/categories/data/models/category_model.dart';

class CategoriesRepo {
  final CategoriesApiService _categoriesApiService = CategoriesApiService();

  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    try {
      final Response response = await _categoriesApiService.getCategories();

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      final List<dynamic> rawCategories =
          data['categories'] as List<dynamic>? ?? <dynamic>[];

      final List<CategoryModel> categories = rawCategories
          .map((dynamic e) =>
              CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(categories);
    } on DioException catch (exception) {
      return Left(Failure(_extractErrorMessage(exception)));
    } catch (exception) {
      return Left(Failure(exception.toString()));
    }
  }

  String _extractErrorMessage(DioException exception) {
    final dynamic data = exception.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return exception.message ?? 'Something went wrong, please try again.';
  }
}
