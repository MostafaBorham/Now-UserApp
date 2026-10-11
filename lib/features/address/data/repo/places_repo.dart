import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/connection/connection_checker.dart';
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

      final dynamic raw = response.data;
      final Map<String, dynamic> body =
          raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

      final int statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        return const Left(Failure(LangKeys.addressSearchFailedKey));
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
      return Left(Failure(_dioError(exception)));
    } catch (_) {
      // Never surface a raw exception string: it ends up in a snackbar.
      return const Left(Failure(LangKeys.somethingWentWrongKey));
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

      final dynamic raw = response.data;
      final Map<String, dynamic> body =
          raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

      final int statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        return const Left(Failure(LangKeys.addressSearchFailedKey));
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
      // Never surface a raw exception string: it ends up in a snackbar.
      return const Left(Failure(LangKeys.somethingWentWrongKey));
    }
  }

  /// Maps a [DioException] to a user-facing message. No response means Google
  /// was never reached; any answer it gave is its own English, often about
  /// the API key, so the customer reads the app's message instead (QA-003
  /// A10).
  static String _dioError(DioException exception) =>
      exception.response == null
      ? LangKeys.serverConnectionFailedKey
      : LangKeys.addressSearchFailedKey;
}
