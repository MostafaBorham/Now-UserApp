import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/places_api_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/place_suggestion_model.dart';






class PlacesRepo {
  final PlacesApiService _placesApiService = PlacesApiService();

  void cancelRequests() => _placesApiService.cancelRequests();


  Future<Either<Failure, List<PlaceSuggestionModel>>> autocomplete({
    required String input,
    required String languageCode,
    required String sessionToken,
    LatLng? locationBias,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _placesApiService.autocomplete(
        input: input,
        languageCode: languageCode,
        sessionToken: sessionToken,
        locationBias: locationBias,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(_extractPlacesError(body)));
      }



      final List<dynamic> rawSuggestions =
          body['suggestions'] as List<dynamic>? ?? <dynamic>[];

      final List<PlaceSuggestionModel> suggestions = rawSuggestions
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) => e['placePrediction'])


          .whereType<Map<String, dynamic>>()
          .map(PlaceSuggestionModel.fromJson)
          .where((PlaceSuggestionModel s) => s.placeId.isNotEmpty)
          .toList();

      return Right(suggestions);
    } on DioException catch (exception) {
      return Left(Failure(_dioError(exception)));
    } catch (_) {

      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }



  Future<Either<Failure, LatLng>> getPlaceLocation({
    required String placeId,
    required String languageCode,
    required String sessionToken,
  }) async {
    if (!await ConnectionChecker.isConnected) {
      return const Left(Failure(LangKeys.noInternetConnectionKey));
    }

    try {
      final Response response = await _placesApiService.getPlaceDetails(
        placeId: placeId,
        languageCode: languageCode,
        sessionToken: sessionToken,
      );

      final Map<String, dynamic> body = response.data as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(Failure(_extractPlacesError(body)));
      }

      final Map<String, dynamic>? location =
          body['location'] as Map<String, dynamic>?;
      final double? latitude = (location?['latitude'] as num?)?.toDouble();
      final double? longitude = (location?['longitude'] as num?)?.toDouble();

      if (latitude == null || longitude == null) {
        return const Left(Failure(LangKeys.failedToGetAddress));
      }

      return Right(LatLng(latitude, longitude));
    } on DioException catch (exception) {
      return Left(Failure(_dioError(exception)));
    } catch (_) {

      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }







  static String _dioError(DioException exception) {
    final Response<dynamic>? response = exception.response;
    if (response == null) return LangKeys.serverConnectionFailedKey;

    final dynamic data = response.data;
    return _extractPlacesError(data is Map<String, dynamic> ? data : null);
  }




  static String _extractPlacesError(Map<String, dynamic>? body) {
    final dynamic error = body?['error'];
    return ApiErrorHandler.extractErrorMessage(
      error is Map<String, dynamic> ? error : body,
    );
  }
}
