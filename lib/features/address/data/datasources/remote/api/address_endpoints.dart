/// API endpoints owned by the address feature.
abstract class AddressEndpoints {
  static const String addresses = '/api/v1/addresses';
  static const String defaultAddress = '/api/v1/addresses/default';

  static int perPage = 15;
  static int page = 1;

  /// Query parameters for getMyAddresses
  static Map<String, dynamic> get getMyAddressesQuery => {
    'per_page': perPage,
    'page': page,
  };

  static String setDefaultAddress(int addressId) =>
      '/api/v1/addresses/$addressId/set-default';

  static String editAddress(int addressId) => '/api/v1/addresses/$addressId';
}
