import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/places_endpoints.dart';

/// Raw calls to the Google **Places API (New)**.
///
/// Like every other API service it only performs the request and returns the
/// Dio [Response]; parsing and error handling belong to `PlacesRepo`. It runs
/// on [DioFactory.getPlacesDio] — the Places host with the API-key header and
/// **without** the app's auth interceptor.
///
/// Cancellation is encapsulated here: every request carries the token of
/// [_canceller], and callers only see [cancelRequests].
class PlacesApiService {
  final Dio _dio = DioFactory.getPlacesDio();
  final RequestCanceller _canceller = RequestCanceller();

  /// Cancels every in-flight request issued by this service instance.
  void cancelRequests() => _canceller.cancel();

  /// Returns address predictions for [input].
  ///
  /// [languageCode] is the current app locale (`ar` / `en`) so Google answers
  /// in the language the user reads. [sessionToken] groups all keystrokes of
  /// one search with its closing [getPlaceDetails] call into a single billed
  /// session. [locationBias] — when the caller knows where the map is looking —
  /// pushes nearby results to the top.
  Future<Response> autocomplete({
    required String input,
    required String languageCode,
    required String sessionToken,
    LatLng? locationBias,
  }) {
    return _dio.post(
      PlacesEndpoints.autocomplete,
      data: <String, dynamic>{
        'input': input,
        'languageCode': languageCode,
        'sessionToken': sessionToken,
        'includedRegionCodes': PlacesEndpoints.includedRegionCodes,
        if (locationBias != null)
          'locationBias': <String, dynamic>{
            'circle': <String, dynamic>{
              'center': <String, double>{
                'latitude': locationBias.latitude,
                'longitude': locationBias.longitude,
              },
              'radius': PlacesEndpoints.locationBiasRadiusMeters,
            },
          },
      },
      cancelToken: _canceller.token,
    );
  }

  /// Fetches the details — most importantly the coordinates — of the place the
  /// user picked. [sessionToken] must be the one the predictions were made
  /// with, otherwise the session is billed twice.
  Future<Response> getPlaceDetails({
    required String placeId,
    required String languageCode,
    required String sessionToken,
  }) {
    return _dio.get(
      PlacesEndpoints.placeDetails(placeId),
      queryParameters: <String, dynamic>{
        'languageCode': languageCode,
        'sessionToken': sessionToken,
      },
      options: Options(
        headers: <String, String>{
          'X-Goog-FieldMask': PlacesEndpoints.placeDetailsFieldMask,
        },
      ),
      cancelToken: _canceller.token,
    );
  }
}
