import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nowdelivery_user_app/core/dio/dio_factory.dart';
import 'package:nowdelivery_user_app/core/dio/request_canceller.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/remote/api/places_endpoints.dart';

class PlacesApiService {
  final Dio _dio = DioFactory.getPlacesDio();
  final RequestCanceller _canceller = RequestCanceller();

  void cancelRequests() => _canceller.cancel();

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
