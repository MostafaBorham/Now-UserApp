import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
import 'package:nowdelivery_user_app/core/dio/api_error_handler.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/places_api_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/place_suggestion_model.dart';

/// Google Places (New) data operations backing the address search.
///
/// Same contract as the rest of the app's repos: `Left` carries a user-facing
/// message (a [LangKeys] key or a raw message — callers apply `.tr()`, which
/// leaves non-key strings untouched), `Right` carries the data.
class PlacesRepo {
  final PlacesApiService _placesApiService = PlacesApiService();

  void cancelRequests() => _placesApiService.cancelRequests();

  /// Address predictions for [input], ready to render as list tiles.
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

      // `suggestions` is omitted entirely — not sent empty — when nothing
      // matches the input.
      final List<dynamic> rawSuggestions =
          body['suggestions'] as List<dynamic>? ?? <dynamic>[];

      final List<PlaceSuggestionModel> suggestions = rawSuggestions
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) => e['placePrediction'])
          // Drops the `queryPrediction` entries, which have no place id and so
          // cannot be resolved to coordinates.
          .whereType<Map<String, dynamic>>()
          .map(PlaceSuggestionModel.fromJson)
          .where((PlaceSuggestionModel s) => s.placeId.isNotEmpty)
          .toList();

      return Right(suggestions);
    } on DioException catch (exception) {
      return Left(Failure(_extractPlacesError(_responseBody(exception))));
    } catch (_) {
      // Never surface a raw exception string: it ends up in a snackbar.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  /// Resolves the coordinates of [placeId], so the map can recenter on the
  /// address the user picked.
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
      return Left(Failure(_extractPlacesError(_responseBody(exception))));
    } catch (_) {
      // Never surface a raw exception string: it ends up in a snackbar.
      return const Left(Failure(LangKeys.serverConnectionFailedKey));
    }
  }

  static Map<String, dynamic>? _responseBody(DioException exception) {
    final dynamic data = exception.response?.data;
    return data is Map<String, dynamic> ? data : null;
  }

  /// Places (New) reports failures as `{"error": {"message": ...}}`, one level
  /// deeper than the app's own API, so [ApiErrorHandler] is fed the nested
  /// object and falls back to its generic message when the shape differs.
  static String _extractPlacesError(Map<String, dynamic>? body) {
    final dynamic error = body?['error'];
    return ApiErrorHandler.extractErrorMessage(
      error is Map<String, dynamic> ? error : body,
    );
  }
}
