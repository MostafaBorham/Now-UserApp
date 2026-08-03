/// Google **Places API (New)** endpoints used by the address search.
///
/// Paths are relative to [DioConstants.placesBaseUrl]
/// (`https://places.googleapis.com/v1`).
abstract class PlacesEndpoints {
  /// `POST` — Autocomplete (New). Turns the typed input into place predictions.
  /// Unlike Place Details it needs no field mask; the response shape is fixed.
  static const String autocomplete = '/places:autocomplete';

  /// `GET` — Place Details (New) for a single place id.
  static String placeDetails(String placeId) => '/places/$placeId';

  /// Sent as `X-Goog-FieldMask` on [placeDetails]. Place Details (New) rejects
  /// a request without one, and every listed field is billed, so this asks for
  /// the bare minimum the address flow needs.
  static const String placeDetailsFieldMask = 'id,location,formattedAddress';

  /// Countries the suggestions are limited to (ISO 3166-1 alpha-2, lowercase).
  /// The app only delivers inside Egypt, so results are filtered rather than
  /// merely biased — widen this list when delivery expands.
  static const List<String> includedRegionCodes = <String>['eg'];

  /// Radius, in metres, of the circle the results are biased towards when the
  /// caller knows where the map is currently looking.
  static const double locationBiasRadiusMeters = 50000;
}
