



abstract class PlacesEndpoints {


  static const String autocomplete = '/places:autocomplete';


  static String placeDetails(String placeId) => '/places/$placeId';




  static const String placeDetailsFieldMask = 'id,location,formattedAddress';




  static const List<String> includedRegionCodes = <String>['sa'];



  static const double locationBiasRadiusMeters = 50000;
}
